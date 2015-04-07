class Catalog::Product < ActiveRecord::Base
  # include Slugable
  MARKETPLACES = %W(rozetka hotline).map{ |m| "#{m}Marketplace".classify.constantize }
  store_accessor :info, :video, :description, :accessories,
                        :newest, :homepage, :hit,
                        :old_price, :main_name
  validates :name, :category, presence: true
  # validates :model, :name, uniqueness: true
  belongs_to :category, class_name: Catalog::Category,
                        foreign_key: :catalog_category_id
  belongs_to :brand, class_name: Catalog::Brand, foreign_key: :catalog_brand_id
  has_many :product_properties, class_name: Catalog::ProductProperty,
                                foreign_key: :catalog_product_id,
                                dependent: :destroy
  has_many :properties, through: :product_properties
  has_many :vendor_products, class_name: Vendor::Product,
                             dependent: :nullify,
                             foreign_key: :catalog_product_id
  has_one :seo, as: :seoable
  scope :bound, -> { joins(:vendor_products) }
  accepts_nested_attributes_for :seo
  accepts_nested_attributes_for :product_properties,
                                reject_if: lambda { |p| p[:property_name].blank? }
  class << self

    def create_from_marketplace(url, opts = {})
      marketplace = MARKETPLACES.detect { |m| url =~ m::HOST }
      raise StandardError, 'Unknown Marketplace' unless marketplace
      params = marketplace.new(url).scrape.except(opts[:ignored_fields])
      params[:category] = opts[:category] if opts[:category]
      params[:model] = opts[:model] if opts[:model]
      create(params)
    end

    def search_marketplaces_by_model(model)
      MARKETPLACES.map do |m|
        m.new(model).search
      end.flatten
    end

    def ransackable_scopes(auth_object = nil)
      if auth_object.try(:admin?)
        [:articul_cont]
      else
        [:articul_cont]
      end
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

    def articul_cont(articul)
      where("id::text ILIKE '%#{articul}%'")
    end

    def recount
      transaction do
        all.eager_load(:vendor_products, :category).find_each do |product|
          product.recount
        end
      end
    end
  end

  def recount
    return if fixed_price?
    rrc = vendor_products.select_rrc
    if rrc
      # @TODO Log if more than one RRC present
      update(price: rrc)
    else
      prices = vendor_products.active.map do |vendor_product|
        vendor_product.price + category.tax_for(vendor_product.price)
      end
      update(price: prices.min)
    end
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

  def reorder(props)
    product_properties.each do |property|
      position = props[property.id.to_s].try(:fetch, 'position').to_i
      property.position = position
    end
    self.save!
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
      product_properties.create(property: property, name: property_value) if property_value.present?
    end
  end

  def remove_property(property_name)
    product_properties.joins(:property)
    .where(catalog_properties: { name: property_name })
    .destroy_all
  end

  def filters=(values)
  end

  def properties=(values)
    Catalog::Product.transaction do
      values.uniq{ |hs| hs.keys.first }.each do |prop|
        property = Catalog::Property
                     .where(name: prop.keys.first)
                     .first_or_create
        p_p = Catalog::ProductProperty
                .new(name: prop.values.first, property: property)

        product_properties << p_p
      end
    end
  end

  def images=(values)
  end

  def category=(value)
    case value
    when String
      cat = Catalog::Category.where(name: value).first_or_create
      super(cat)
    when Catalog::Category
      super(value)
    else
      raise ArgumentError, 'Expected Category or category name'
    end
  end

  def brand=(value)
  end

  def copy_properties_to_category
    to_add = properties - category.properties
    category.properties << to_add
  end

end
