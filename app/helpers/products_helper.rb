module ProductsHelper
  include AutoHtml
  def price_for(product, quantity=1)
    price = product.bound? ? (product.price * quantity) : 0
    if price.to_f.ceil == 0
      return %{Нет в наличии}
    end
    old_price = product.old_price.to_f.ceil * quantity

    price_inner = if (old_price > 0) && (old_price > price)
      content_tag(:span, class: 'product_old-price') do
        old_price.to_s
      end +
      "#{price} грн."
    else
      "#{price} грн."
    end

    if @product == product
      content_tag(:span, itemprop: :price) do
        tag(:meta, itemprop: 'priceCurrency', content: 'UAH') +
        price_inner
      end
    else
      price_inner
    end



  end

  def product_properties_for(product)
    product.product_properties
      .with_value
      .includes(:property)
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

  def breadcrumbs_for_product(product)
    top_taxon = product.category.taxon.parent
    category = product.category
    brand_link = link_to(c_path(slug: category.slug, id: category, b: product.brand.id), itemprop: 'url', itemscope: '') { content_tag(:span, itemprop: 'title', itemscope: '') do product.brand.name end } rescue nil
    breadcrumbs_ary = [
      link_to(root_path, itemprop: 'url', itemscope: '') { content_tag(:span, itemprop: 'title', itemscope: '') do Conf[:site_name] end },
      link_to(t_path(slug: top_taxon.slug, id: top_taxon), itemprop: 'url', itemscope: '') { content_tag(:span, itemprop: 'title', itemscope: '') do top_taxon.name end } ,
      link_to(c_path(slug: category.slug, id: category), itemprop: 'url', itemscope: '') { content_tag(:span, itemprop: 'title', itemscope: '') do category.name end },
      brand_link,
      content_tag(:span, itemprop: 'title', itemscope: '') { product.name }
    ].compact
    breadcrumbs_body = breadcrumbs_ary.map do |t|
      content_tag(:li, itemtype: 'http://data-vocabulary.org/Breadcrumb', itemscope: '') { t }
    end.join(' > ')
    content_tag(:ul, class: 'breadcrumbs') do
      breadcrumbs_body.html_safe
    end
  rescue
    nil
  end

  def breadcrumbs_for_taxon(taxon)
    [
      link_to(Conf[:site_name], root_path),
      taxon.name
    ].compact.join(' > ').html_safe
  end

  def breadcrumbs_for_category(category)
    return if category.taxon.nil?
    top_taxon = category.taxon.parent
    [
      link_to(Conf[:site_name], root_path),
      link_to(top_taxon.name, t_path(slug: top_taxon.slug, id: top_taxon)),
      category.name
    ].compact.join(' > ').html_safe
  end

end
