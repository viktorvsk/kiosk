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
    brand_link = link_to(product.brand.name, c_path(slug: category.slug, id: category, b: product.brand.id)) rescue nil
    [
      link_to(Conf[:site_name], root_path),
      link_to(top_taxon.name, t_path(slug: top_taxon.slug, id: top_taxon)),
      link_to(category.name, c_path(slug: category.slug, id: category)),
      brand_link,
      product.name
    ].compact.join(' > ').html_safe
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
