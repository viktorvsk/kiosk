class Catalog::ProductFilterValue < ActiveRecord::Base
  validates :product, :filter_value, presence: true
  belongs_to :product, class_name: Catalog::Product,
                       foreign_key: :catalog_product_id
  belongs_to :filter_value, class_name: Catalog::FilterValue,
                            foreign_key: :catalog_filter_value_id
end
