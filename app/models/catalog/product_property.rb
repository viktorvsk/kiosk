class Catalog::ProductProperty < ActiveRecord::Base
  validates :name, :property, presence: true
  validates :product, presence: true, if: -> { product.present? }
  validates :catalog_property_id, uniqueness: { scope: :catalog_product_id }
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
    return if value.blank? || value == property.name
    prop = Catalog::Property.where(name: value).first_or_create
    self[:catalog_property_id] = prop.id
  end

end
