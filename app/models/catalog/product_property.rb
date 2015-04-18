class Catalog::ProductProperty < ActiveRecord::Base
  validates :property, presence: true
  validates :product, presence: true, if: -> { product.present? }
  validates :catalog_product_id, uniqueness: { scope: [:catalog_property_id] }
  belongs_to :property, class_name: Catalog::Property,
                        foreign_key: :catalog_property_id
  belongs_to :product, class_name: Catalog::Product,
                       foreign_key: :catalog_product_id
  delegate :category, to: :product

  def property_name
    property.try(:name)
  end

  def property_name=(value)
    value.strip!
    return if value.blank? || value == property.try(:name)
    prop = Catalog::Property.where(name: value).first_or_create
    self[:catalog_property_id] = prop.id
  end

  def modify!(prop_name, prop_val)
    prop_name.strip!
    prop_val.strip!
    changes_prop_name = prop_name != property_name
    prop_name_taken = product.product_properties.where(name: prop_name).present?
    return false if changes_prop_name && prop_name_taken
    return true if prop_val == name && !changes_prop_name
    # destroy! and return if prop_val.blank?
    self.property = Catalog::Property.where(name: prop_name).first_or_create! if changes_prop_name
    self.name = prop_val
    save!
  end


end
