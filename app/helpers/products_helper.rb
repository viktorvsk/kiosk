module ProductsHelper
  include AutoHtml
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

  def product_properties_for(product)
    product.product_properties.includes(:property)
      .sort_by(&:position)
      .first(8)
      .map{ |pp| "<b>#{pp.property_name}</b>: #{pp.name};" }
      .join('<br/>')
      .html_safe
  end

  def video_for(url)
    auto_html(url) do
      html_escape
      youtube
      vimeo
      google_video
    end
  end

end
