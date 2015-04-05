class Catalog::CategoryProperty < ActiveRecord::Base
  validates :position, presence: true
  validates :category, presence: true, if: -> { category.present? }
  validates :catalog_property_id, uniqueness: { scope: :catalog_category_id }
  belongs_to :property, class_name: Catalog::Property, foreign_key: :catalog_property_id
  belongs_to :category, class_name: Catalog::Category, foreign_key: :catalog_category_id
  delegate :name, to: :property
end
