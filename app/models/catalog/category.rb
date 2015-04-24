class Catalog::Category < ActiveRecord::Base
  after_save :recount_products
  store_accessor :info, :tax, :tax_max, :tax_threshold, :description
  validates :name, presence: true
  has_many :products, class_name: Catalog::Product, dependent: :destroy, foreign_key: :catalog_category_id
  has_many :vendor_products, through: :products, class_name: ::Vendor::Product
  has_many :category_properties, class_name: Catalog::CategoryProperty,
                                 foreign_key: :catalog_category_id,
                                 autosave: true,
                                 dependent: :delete_all
  has_many :category_filters, class_name: Catalog::CategoryFilter,
                              foreign_key: :catalog_category_id,
                              dependent: :delete_all,
                              autosave: true
  has_many :filters, through: :category_filters
  has_many :filter_values, through: :category_filter_values
  has_many :properties, through: :category_properties
  belongs_to :taxon, class_name: Catalog::Taxon, foreign_key: :catalog_taxon_id
  has_one :seo, as: :seoable, dependent: :destroy

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

  private

  def recount_products
    byebug
    Catalog::CategoryProductsUpdater.async_update(id) if info_changed?
  end

end
