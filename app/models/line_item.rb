class LineItem < ActiveRecord::Base

  belongs_to :order
  belongs_to :product, class_name: Catalog::Product, foreign_key: :catalog_product_id

end
