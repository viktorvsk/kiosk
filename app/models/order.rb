class Order < ActiveRecord::Base
  has_many :line_items, dependent: :destroy
  has_many :products, through: :line_items
  belongs_to :user

  def add_product(product, quantity=1)
    product = product.kind_of?(Catalog::Product) ? product : Catalog::Product.where(id: product).first
    if product
      if already_added = line_items.detect{ |li| li.product == product }
        already_added.increment! :quantity, quantity
      else
        line_items.create(product: product, quantity: quantity)
      end
    else
      false
    end

  end

  def total_sum
    if state == 'in_cart'
      line_items.map{ |li| li.product.price * li.quantity }.sum
    else
      line_items.map{ |li| li.price * li.quantity }.sum
    end
  end
end
