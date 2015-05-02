module ProductsHelper
  def price_for(product, quantity=1)
    price = product.bound? ? (product.price * quantity) : 0
    return "Нет в наличии" if price.to_f.ceil == 0
    old_price = product.old_price.to_f.ceil * quantity

    if (old_price > 0) && (old_price > price)
      content_tag(:span, class: 'product_old-price') do
        old_price.to_s
      end +
      "#{price} грн."
    else
      "#{price} грн."
    end

  end
end
