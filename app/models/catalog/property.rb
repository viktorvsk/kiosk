class Catalog::Property < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  has_many :product_properties, class_name: Catalog::ProductProperty,
                                foreign_key: :catalog_property_id,
                                dependent: :destroy
  has_many :category_properties, class_name: Catalog::CategoryProperty,
                                foreign_key: :catalog_property_id,
                                dependent: :destroy
end
