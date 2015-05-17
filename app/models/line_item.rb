class LineItem < ActiveRecord::Base
  validates :quantity, numericality: { less_than_or_equal_to: 10, greater_than_or_equal_to: 1 }
  belongs_to :order
  belongs_to :product, class_name: Catalog::Product, foreign_key: :catalog_product_id
  store_accessor :info, :vendor, :serial_numbers
  def fix_price!
    update(price: client_price, vendor_price: in_price)
  end

  def income
    client_price - in_price
  end

  def in_price
    p = if order.state == 'in_cart'
      if product.fixed_price?
        (product.price.to_i - product.fixed_tax.to_i)
      else
        product.in_price
      end
    else
      vendor_price
    end

    (p.to_i * quantity).to_f.ceil

  end

  def client_price
    p = if order.state == 'in_cart'
      product.price
    else
      price
    end

    (p.to_i * quantity).to_f.ceil
  end

end
