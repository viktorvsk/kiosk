module ProductsHelper
  def price_for(product, quantity=1)
    product.bound? ?  "#{product.price * quantity} грн." : "Нет в наличии"
  end
end
