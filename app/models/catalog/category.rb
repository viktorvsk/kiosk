class Catalog::Category < ActiveRecord::Base
  store_accessor :info, :tax, :tax_max, :tax_threshold
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
  has_many :properties, through: :category_properties

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

  def reorder_all
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

end
