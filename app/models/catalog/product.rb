require 'open-uri'
class Catalog::Product < ActiveRecord::Base
  include Slugable
  SEO_MAPPER = {
    'название' => :name,
    'цена' => :price
  }
  SEO_ATTRS = %w(название цена).join('|')
  before_create :copy_properties_from_category
  before_create :copy_filters_from_category
  after_save :recount_unfixed
  MARKETPLACES = %W(rozetka hotline brain erc).map{ |m| "#{m}Marketplace".classify.constantize }
  store_accessor :info, :video, :description, :accessories,
                        :newest, :homepage, :hit,
                        :old_price, :main_name,
                        :url
  validates :name, :category, presence: true
  # validates :model, :name, uniqueness: true
  belongs_to :category, -> { includes(:taxon) },
                        class_name: Catalog::Category,
                        foreign_key: :catalog_category_id
  belongs_to :brand, class_name: Catalog::Brand, foreign_key: :catalog_brand_id
  has_many :line_items, dependent: :destroy, foreign_key: :catalog_product_id
  has_many :product_properties, class_name: Catalog::ProductProperty,
                                foreign_key: :catalog_product_id,
                                dependent: :delete_all,
                                autosave: true
  has_many :product_filters, class_name: Catalog::ProductFilterValue,
                     foreign_key: :catalog_product_id,
                     dependent: :delete_all,
                     autosave: true
  has_many :properties, through: :product_properties
  has_many :images, as: :imageable, dependent: :destroy
  has_many :vendor_products, class_name: Vendor::Product,
                             dependent: :nullify,
                             foreign_key: :catalog_product_id
  has_one :seo, as: :seoable, dependent: :destroy
  scope :bound, -> { joins(:vendor_products) }
  scope :zeros_last, -> { order('catalog_products.price = 0') }
  scope :with_price, -> { where('price > 0') }
  accepts_nested_attributes_for :seo
  accepts_nested_attributes_for :images, allow_destroy: true
  accepts_nested_attributes_for :product_properties,
                                reject_if: lambda { |p| p[:property_name].blank? }
  class << self

    def ransackable_scopes(auth_object = nil)
      [:filters_cont, :main_search]
    end

    def by_category_params(params)
      q = {
        price_gteq: params[:min],
        price_lteq: params[:max],
        main_search: params[:name],
        brand_id_in: params[:b].to_s.split(','),
        filters_cont: params[:f]
      }
      all.ransack(q).result
    end

    def main_search(str)
      str = str.to_s.strip
      q = [
        %{to_char(id, '99999999') ILIKE :name},
        %{name ILIKE :name},
        %{name ILIKE :translit_name}
      ].join(" OR ")
      all.where(q, name: "%#{str}%", translit_name: "%#{Russian.translit(str)}%")
    end

    def top(top_name)
      where("catalog_products.info->'#{top_name}' = '1'")
    end

    def filters_cont(filters_str)
      filter(filters_str.to_s.split(',').compact)
    end

    def filter(fvalues_ids)
      grouped = Catalog::FilterValue.where(id: fvalues_ids.map(&:to_i)).to_group
      query = []
      grouped.each_value do |fvalues|
        ids = fvalues.map(&:id).join(', ')
        query << %(
          SELECT catalog_products.id
          FROM catalog_products
          INNER JOIN
            catalog_product_filter_values ON catalog_product_filter_values.catalog_product_id = catalog_products.id
          WHERE
            catalog_product_filter_values.catalog_filter_value_id IN (#{ids})
        )
      end

      query = query.join("\nINTERSECT\n")
      ids = ActiveRecord::Base.connection.execute(query).map{ |row| row['id'] }
      where(id: ids)
    end

    def marketplace_by_url(url)
      host = URI.parse(url.to_s.strip).host.to_s
      MARKETPLACES.detect { |m| m::HOST =~ host }
    end

    def create_from_marketplace(url, opts = {})
      marketplace = marketplace_by_url(url)
      raise StandardError, 'Unknown Marketplace' unless marketplace
      params = marketplace.new(url).scrape.except(opts[:ignored_fields])
      params[:category] = opts[:category] if opts[:category]
      params[:model] = opts[:model] if opts[:model]
      create(params)
    end

    # def search_marketplaces_by_model(model)
    #   MARKETPLACES.map do |m|
    #     m.new(model).search
    #   end.flatten
    # end

    def search_marketplaces_by_model(model)
      Parallel.map(MARKETPLACES, in_threads: MARKETPLACES.count) do |marketplace|
        begin
          marketplace.new(model).search
        rescue Exception
          nil
        end
      end.flatten
    end

    def unbound
      joins('LEFT JOIN vendor_products ON vendor_products.catalog_product_id = catalog_products.id')
        .where('vendor_products.catalog_product_id IS NULL')
    end

    def bound_with(number)
      select('catalog_products.*')
        .joins(:vendor_products)
        .group('catalog_products.id')
        .having('count(vendor_products.id) >=  ?', number)
    end

    def recount
      transaction do
        all.eager_load(:vendor_products, :category).find_each do |product|
          product.recount
        end
      end
    end
  end

  def bound?
    #vendor_products.active.present?
    price.to_i > 0
  end

  def accessories_products
    return unless accessories.present?
    self.class.where(id: accessories.split).with_price.uniq
  end

  def preview_path
    images.includes(:imageable).first.try(:to_s) || "product_missing.png"
  end

  def seo_template(attribute)
    Conf[:seo_template_product].gsub(/\{\{(#{SEO_ATTRS})\}\}/){ self.send(SEO_MAPPER[$1]) }
  end

  def recount
    return if fixed_price?
    update(price: price_to_recount)
  end

  def in_price
    (vendor_products.rrc.active.max_by(&:price).try(:rrc) || vendor_products.active.min_by(&:price).try(:price)).to_f.ceil
  end

  def bind(vendor_product)
    vendor_product.update(product: self)
  end

  def unbind_all
    vendor_products.update_all(product: nil)
  end

  def sync_properties_position
    category_properties = category.category_properties.select(:catalog_property_id, :position)
    product_properties.find_each do |product_property|
      category_property = category_properties.detect{ |c_p| c_p.catalog_property_id == product_property.catalog_property_id }
      if (pos = category_property.try(:position)) && pos != product_property.position
        product_property.update(position: pos)
      end
    end

  end

  def update_from_marketplace
    found = self.class.search_marketplaces_by_model(model)
    random_url = found.select{ |h| h[:price].to_i > 0 }.sample[:url]
    result = self.class.marketplace_by_url(random_url).new(random_url).scrape.slice(:description, :properties)
    self.description = result[:description] if result[:description].present?
    self.properties = result[:properties] if result[:properties].present?
  rescue Exception
    nil
  end

  def reorder(props)
    product_properties.each do |property|
      position = props[property.id.to_s].try(:fetch, 'position').to_i
      property.position = position
    end
    self.save!
  end

  def similars(delta=25,number=4)
    delta = delta / 100
    p = price.to_i
    delta_price = p * delta
    similar_price = p - delta_price..p + delta_price
    category.products.where(price: similar_price).where.not(id: id).order("RANDOM()").limit(number).sort_by(&:price)
  end

  def set_property(property_name, property_value)
    property_name, property_value = property_name.try(:strip), property_value.try(:strip)

    property = Catalog::Property.where(name: property_name).first_or_create
    if property.id.in? product_properties.pluck(:catalog_property_id)
      if property_value.present?
        product_properties.where(property: property)
        .first
        .update(name: property_value)
      else
        remove_property(property_name)
      end
    else
      if property_value.present?
        product_properties.new(property: property, name: property_value)
        save if persisted?
      end
    end
  end

  def remove_property(property_name)
    product_properties.joins(:property)
    .where(catalog_properties: { name: property_name })
    .destroy_all
  end

  def filters=(values)
    return if category.blank? || category.new_record?
    values.uniq{ |hs| hs.keys.first }.each do |filter|
      f_name = filter.keys.first
      f_val = filter.values.first
      f = category.add_filter(f_name, category.name)
      f_v = f.add_value(f_val, f.name)
      product_filters.new(filter_value: f_v, filter: f)
    end
    save if persisted?
  end

  def properties=(values)
    values.uniq{ |hs| hs.keys.first }.each do |prop|
      set_property(prop.keys.first, prop.values.first)
    end
  end

  def images=(values)
    values.each { |v| scrape_image(v) }
  end

  def evotex_images=(values)
    values.each do |image_path|
      image_path = image_path[1..-1]
      image_path.gsub!(/\?.+/, '')
      image_path.gsub!(/\.product\./, '.original.')
      image_file = File.new Rails.root.join('tmp', image_path)
      images.create(attachment: image_file)
    end
  end

  def images_from_url
  end

  def images_from_pc
  end

  def images_from_url=(value)
    return unless value.present?
    url = URI.encode URI.decode value.strip
    marketplace = Catalog::Product.marketplace_by_url(url)
    img_urls = marketplace.new(url).scrape[:images]
    img_urls.each do |img_url|
      scrape_image(img_url)
    end
  end

  def scrape_image(url)
    img_url = URI.encode URI.decode url.to_s.strip
    tempfile = Tempfile.new([File.basename(img_url), File.extname(img_url)])
    tempfile.binmode
    tempfile << open(img_url).read
    tempfile.close
    images << Image.new(attachment: tempfile)
  end

  def images_from_pc=(values)
    values.each { |v| images << Image.new(attachment: v) }
  end

  def category=(value)
    case value
    when String
      cat = Catalog::Category.where(name: value).first_or_create
      super(cat)
    when Catalog::Category
      super(value)
    else
      errors.add(:catalog_category_id, 'Expected Category or category name')
      # raise ArgumentError, 'Expected Category or category name'
    end
  end

  def brand=(value)
  end

  def copy_properties_to_category
    to_add = properties - category.properties
    category.properties << to_add
  end

  def copy_properties_from_category
    ids = product_properties.map(&:catalog_property_id)
    category.category_properties.each do |category_property|
      next if ids.include?(category_property.property.id)
      params = { property: category_property.property, position: category_property.position }
      new_or_create = new_record? ? :new : :create
      product_properties.send(new_or_create, params)
    end
  end

  def copy_filters_from_category
    ids = product_filters.map(&:catalog_filter_id)
    category.category_filters.each do |category_filter|
      next if ids.include?(category_filter.filter.id)
      params = { filter: category_filter.filter }
      new_or_create = new_record? ? :new : :create
      product_filters.send(new_or_create, params)
    end
  end

  private


  def price_to_recount
    rrc = vendor_products.select_rrc
    if rrc > 0
      rrc
    else
      prices = vendor_products.active.map do |vendor_product|
        vendor_product.price + category.tax_for(vendor_product.price)
      end
      prices.min
    end
  end

  def recount_unfixed
    return if fixed_price? || !fixed_price_changed?
    update_column(:price, price_to_recount)
  end

  ransacker :id do
    Arel.sql("to_char(\"#{table_name}\".\"id\", '99999999')")
  end

end
