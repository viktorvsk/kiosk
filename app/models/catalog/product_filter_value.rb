class Catalog::ProductFilterValue < ActiveRecord::Base
  validates :product, :filter, presence: true, if: -> { product.present? }
  validates :catalog_product_id, uniqueness: { scope: :catalog_filter_id }
  belongs_to :product, class_name: Catalog::Product,
                       foreign_key: :catalog_product_id
  belongs_to :filter_value, class_name: Catalog::FilterValue,
                            foreign_key: :catalog_filter_value_id
  belongs_to :filter, class_name: Catalog::Filter,
                            foreign_key: :catalog_filter_id

  def position
    product.category.category_filters.where(catalog_filter_id: filter.id).first.position rescue 0
  end
end
