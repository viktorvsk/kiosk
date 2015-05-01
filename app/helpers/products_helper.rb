module ProductsHelper
  def price_for(product, quantity=1)
    price = product.bound? ? (product.price * quantity) : 0
    return "Нет в наличии" if price.to_f.ceil == 0

    if product.old_price.to_f.ceil > 0
      content_tag(:span, class: 'product_old-price') do
        product.old_price.to_f.ceil.to_s
      end +
      "#{price} грн."
    else
      "#{price} грн."
    end

  end
end
