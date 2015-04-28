module ProductsHelper
  def price_for(product)
    product.bound? ?  "#{product.price} грн." : "Нет в наличии"
  end
end
