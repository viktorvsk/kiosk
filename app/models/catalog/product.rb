require 'open-uri'
class Catalog::Product < ActiveRecord::Base
  include Slugable
  SEO_MAPPER = {
    'название'              => :name,
    'главное-имя'           => :main_name,
    'цена'                  => :price,
    'старая-цена'           => :old_price,
    'название-категории'    => :categroy_name,
    'название-категории-1'  => :category_single_name,
    'бренд'                 => :brand_name
  }
  SEO_ATTRS = SEO_MAPPER.keys.join('|')
  before_create :copy_properties_from_category
  before_create :copy_filters_from_category
  after_save :recount_unfixed
  store_accessor :info, :video, :description, :accessories,
                        :newest, :homepage, :hit,
                        :old_price, :main_name,
                        :url, :fixed_tax,
                        :vendor, :vendor_code, :vendor_category
  validates :name, :category, presence: true
  # validates :model, :name, uniqueness: true
  belongs_to :category, -> { includes(:taxon) },
                        class_name: Catalog::Category,
                        foreign_key: :catalog_category_id
  belongs_to :brand, class_name: Catalog::Brand, foreign_key: :catalog_brand_id
  has_many :comments, as: :commentable
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
  scope :with_price, -> { where('catalog_products.price > 0') }
  accepts_nested_attributes_for :seo
  accepts_nested_attributes_for :images, allow_destroy: true
  accepts_nested_attributes_for :product_properties,
                                reject_if: lambda { |p| p[:property_name].blank? }
  class << self

    def active_marketplaces
      Conf['marketplaces'].split.map{ |m| "#{m}Marketplace".classify.constantize rescue nil }.compact
    end

    def ransackable_scopes(auth_object = nil)
      [:filters_cont, :main_search, :with_filters, :with_properties, :with_bound, :top]
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

    def with_warranty
      joins(:product_properties).where(catalog_product_properties: { catalog_property_id: Catalog::Property.warranty.id })
    end

    def with_filters(val)
      if val == 'y'
        all
          .joins(:product_filters)
          .where
          .not(catalog_product_filter_values: {catalog_filter_value_id: nil})
          .uniq
      elsif val == 'n'
        all
          .includes(:product_filters)
          .where(catalog_product_filter_values: {catalog_filter_value_id: nil})
          .uniq
      end
    end

    def with_properties(val)
      if val == 'y'
        all
          .joins(:product_properties)
          .where("catalog_product_properties.name != ''")
          .uniq
      elsif val == 'n'
        all
          .includes(:product_properties)
          .where("catalog_product_properties.catalog_product_id IS NULL OR catalog_product_properties.name = '' OR catalog_product_properties.name IS NULL")
          .uniq
      end
    end

    def with_bound(val)
      if val == 'y'
        all.joins(:vendor_products).uniq
      elsif val == 'n'
        all.joins('LEFT JOIN vendor_products ON vendor_products.catalog_product_id = catalog_products.id').group('catalog_products.id').having('COUNT(vendor_products.id) = 0')
      end
    end

    def main_search(str)
      str = str.mb_chars.downcase.to_s
      tpl_ids = all.tpl_search(str).pluck(:id)
      wrd_ids = all.words_search(str).pluck(:id)
      ids = tpl_ids + wrd_ids
      if (ids.size < 5) && (Conf['b.search_with_similars'] == 't')
        similars = all.similarity_search(str)
        ids += similars.pluck(:id) if similars
      end

      ids.uniq!
      ids.present? ? all.where(id: ids) : Catalog::Product.none
    rescue
      Catalog::Product.none
    end

    def tpl_search(str)
      str = str.to_s.strip.split.join("%")
      q = []
      h = {}
      if str =~ /\A\d+\Z/
        q << %{catalog_products.id = :id}
        h[:id] = str
      else
        name = "%#{str}%"
        tr_name = Russian.translit(name)
        q << %{name ILIKE :name}
        q << %{name ILIKE :translit_name} if name != tr_name
        h[:name] = name
        h[:translit_name] = tr_name
      end
      q = q.join(" OR ")
      q.present? ? all.where(q, h) : Catalog::Product.none
    end

    def words_search(str)
      words = str.to_s.strip.split.map{ |w| "#{w}:*"}
      words = words.map do |w|
        t = Russian.translit(w)
        if t == w
          t
        else
          "(#{t} | #{w})"
        end
      end
      search_str = words.join('&')
      query = "to_tsvector('english', name) @@ :q"
      all.where(query, q: search_str)
    end

    def similarity_search(str)
      return if str =~ /((\%3D)|(=))[^\n]*((\%27)|(\')|(\-\-)|(\%3B)|(;))/
      return if str =~ /\w*((\%27)|(\'))((\%6F)|o|(\%4F))((\%72)|r|(\%52))/
      return if str =~ /(\%27)|(\')|(\-\-)|(\%23)|(#)/

      all
          .where("similarity(name, :q) > :similar_distance", q: str, similar_distance: Conf['similar_distance'].to_f)
          .order("similarity(name, '#{str}')")
          .limit(10)
    end

    def top(top_name)
      where("catalog_products.info->'#{top_name}' = '1'")
    end

    def top_products
      where("info->'newest' = '1' OR info->'hit'='1' OR info->'homepage'='1'")
    end

    def all_properties
      all.map(&:product_properties).map{ |p| p.map(&:property) }.flatten.uniq
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
      active_marketplaces.detect { |m| m::HOST =~ host }
    end

    def create_from_marketplace(url, opts = {})
      marketplace = marketplace_by_url(url)
      raise StandardError, 'Unknown Marketplace' unless marketplace
      params = marketplace.new(url).scrape.except(opts[:ignored_fields])
      params[:properties].reverse!
      params[:category] = opts[:category] if opts[:category]
      params[:model] = opts[:model] if opts[:model]
      create(params)
    end

    def search_marketplaces_by_model(model)
      Parallel.map(active_marketplaces, in_threads: active_marketplaces.count) do |marketplace|
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

  ### SEO TEMPLATE ###
  def category_name
    category.name
  end

  def brand_name
    brand.try(:name).to_s
  end

  def category_single_name
    category.s_name.to_s
  end
  ### SEO TEMPLATE ###

  def bound?
    #vendor_products.active.present?
    price.to_i > 0
  end

  def accessories_products
    return unless accessories.present?
    self.class.where(id: accessories.split).with_price.uniq
  end

  def preview_path
    images.includes(:imageable).sort_by(&:position).first.try(:to_s) || "/product_missing.png"
  end

  def seo_template(attribute)
    Conf[:seo_template_product].gsub(/\{\{(#{SEO_ATTRS})\}\}/){ self.send(SEO_MAPPER[$1]) rescue '' }
  end

  def recount
    return if fixed_price?
    update(price: price_to_recount)
  end

  def in_price
    active_vendor.try(:price).to_f.ceil
  end

  def active_vendor
    return if fixed_price?
    vendor_products.rrc.active.max_by(&:price) ||
      vendor_products.active.min_by(&:price)
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

  def empty_attributes
    attributes
      .select{ |k, v| v.blank? }
      .keys
      .map{ |k| I18n.t("activerecord.attributes.catalog/product.#{k}") }
      .join('; ')
  end

  def stats
    stats = {
      '<b>Название</b>' => name,
      '<b>Пустые поля</b>' => empty_attributes,
      '<b>Характеристик</b>' => product_properties.where.not(name: nil).count,
      '<b>Фильтров</b>' => product_filters.where.not(filter_value: nil).count,
      '<b>Изображений</b>' => images.count,
      '<b>Длина описания</b>' => description.to_s.size
    }
    stats.to_a.map{ |stat| stat.join(": ") }.join("\n<br/>")

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

  def warranty(warranty_id=nil)
    warranty_id ||= Catalog::Property.warranty.try(:id)
    return unless warranty_id
    product_properties.where("catalog_property_id = :w AND name != '' AND name IS NOT NULL", w: warranty_id).first
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

  def multiple_remote_images
  end

  def multiple_remote_images=(img_urls)
    img_urls = img_urls.to_s.split("\n")
    return if img_urls.blank?
    img_urls.each do |url|
      scrape_image(url)
    end
  end

  def scrape_image(url)
    img_url = URI.encode URI.decode url.to_s.strip
    tempfile = Tempfile.new([File.basename(img_url), File.extname(img_url)])
    tempfile.binmode
    begin
      tempfile << open(img_url).read rescue return
      tempfile.close
      i = Image.new(imageable_type: Catalog::Product)
      i.attachment = tempfile
      images << i
    rescue
      nil
    ensure
      tempfile.close
    end
  end

  def images_from_pc=(values)
    values.each do |v|
      i = Image.new(imageable_type: Catalog::Product)
      i.attachment = v
      images << i
    end
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
    # TODO: Ugly decision
    product_filters.map do |prod_fltr|
      prod_fltr.destroy if prod_fltr.filter.category_filters.first.category != category
    end
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
