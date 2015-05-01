class LineItem < ActiveRecord::Base

  belongs_to :order
  belongs_to :product, class_name: Catalog::Product, foreign_key: :catalog_product_id

  def fix_price
    update(price: product.price, vendor_price: product.in_price)
  end

end
