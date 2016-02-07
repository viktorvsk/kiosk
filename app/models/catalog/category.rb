class Catalog::Category < ActiveRecord::Base
  SEO_MAPPER = {
    'имя-мн'                => :name,
    'имя-ед'                => :s_name
  }
  SEO_ATTRS = SEO_MAPPER.keys.join('|')
  include Slugable
  # after_update :recount_products, :rerender_menu
  store_accessor :info, :tax, :tax_max, :tax_threshold, :description, :s_name
  validates :name, presence: true
  has_many :products, class_name: Catalog::Product, dependent: :destroy, foreign_key: :catalog_category_id
  has_many :brands, through: :products
  #has_many :vendor_products, through: :products, class_name: ::Vendor::Product
  has_many :category_properties, class_name: Catalog::CategoryProperty,
                                 foreign_key: :catalog_category_id,
                                 autosave: true,
                                 dependent: :delete_all
  has_many :category_filters, class_name: Catalog::CategoryFilter,
                              foreign_key: :catalog_category_id,
                              dependent: :delete_all,
                              autosave: true
  has_many :filters, through: :category_filters
  has_many :filter_values, through: :category_filters, source: :filter
  has_many :properties, through: :category_properties
  has_many :aliases, as: :aliasable, dependent: :destroy
  belongs_to :taxon, class_name: Catalog::Taxon, foreign_key: :catalog_taxon_id, touch: true
  has_one :seo, as: :seoable, dependent: :destroy
  accepts_nested_attributes_for :seo
  accepts_nested_attributes_for :aliases, allow_destroy: true
  
  def self.pricelist_association
    where(active: true)
      .joins(:products)
      .where('catalog_products.price > 0')
      .select('catalog_categories.id, catalog_categories.name')
      .uniq
  end

  def tax_for(value)
    value = value.to_f.ceil
    if value > tax_threshold.to_f.ceil
      tax_max.to_f.ceil
    else
      tax.to_f.ceil
    end
  end

  def reorder(props)
    category_properties.each do |property|
      position = props[property.id.to_s].try(:fetch, 'position').to_i
      property.position = position
    end
    self.save!
  end

  def reorder_all_properties
    category_properties_ids = category_properties.pluck(:id)
    products_ids = products.pluck(:id)
    products_properties_groups = Catalog::ProductProperty.
      joins(:product, :property, property: :category_properties).
      includes(:property).
      where('catalog_category_properties.id IN (?)', category_properties_ids).
      where('catalog_products.id IN (?)', products_ids).
      uniq.
      group_by{ |pp| pp.property.id }

    products_properties_groups.each do |prop_id, prod_props|
      prod_props_ids = prod_props.map(&:id)
      position = category_properties.where(catalog_property_id: prop_id).first.position
      Catalog::ProductProperty.where(id: prod_props_ids).update_all(position: position)
    end

  end

  def all_aliases
    aliases.map(&:name).join("\n")
  end

  def all_aliases=(values)
    aliases.destroy_all
    to_create = values.split("\n").reject(&:blank?)
    to_create.map! do |v|
      { name: v }
    end
      aliases.create(to_create)
  end

  def add_filter(filter_name, postfix = nil)
    return unless filter_name.present?
    filter_name = filter_name.strip
    disp_name = filter_name
    filter_name = "#{filter_name} (#{postfix})" if postfix.present?
    filter_name_search = filter_name.mb_chars.downcase.to_s
    filter = Catalog::Filter.where('LOWER(name) = ?', filter_name_search).first
    filter ||= Catalog::Filter.create(name: filter_name, display_name: disp_name)
    begin
      filters << filter
    rescue ActiveRecord::RecordInvalid
      # Category already has this filter
    end
    filter
  end

  def products_for_price
    products.select('catalog_products.price, catalog_products.name, catalog_products.id, catalog_products.slug').with_price.includes(:product_properties, images: [:imageable])
  end

  def reorder_filter_values=(values)
    return unless values.present?
    values.each do |filter_value_id, position_hash|
      Catalog::FilterValue.find(filter_value_id).update(position_hash.permit(:position))
    end
  end

  def reorder_filters=(values)
    return unless values.present?

    values.each do |filter_id, position_hash|
      Catalog::CategoryFilter.find(filter_id).update(position_hash.permit(:position))
    end
  end

  def seo_template
    Conf[:seo_template_category].gsub(/\{\{(#{SEO_ATTRS})\}\}/){ self.send(SEO_MAPPER[$1]) rescue '' }
  end

  def self.products_pricelist_count
    where(active: true).joins(:products).count
  end

  private

  def recount_products
    Catalog::CategoryProductsUpdater.async_update(id) if info_changed?
  end

  def rerender_menu
    Catalog::Taxon.expire_menu_cache_fragment if catalog_taxon_id_changed?
  end

end
