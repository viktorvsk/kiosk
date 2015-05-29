class GrillyMarketplace < BasicMarketplace
  HOST = /grilly/

  private

  def search_query
    "http://grilly.ua/index.php?route=product/search&filter_name=#{@query}"
  end

  def search_found_selector
    '.product-list > div'
  end

  def search_results_mapper(product)
    byebug
    res = {}
    res[:name]  = product.at_css('.name a').text.strip
    res[:url]   = product.at_css('.name a')['href'].to_s
    res[:image] = product.at_css('.image')['src'].to_s
    price_node  = product.at_css('.cart input')['value']

    if price_node.present?
      res[:price] = price_node.to_f.ceil
    else
      res[:do_not_show] = false
      'Нет в наличии'
    end

    res
  rescue
    nil
  end

  def product_page_scraper(page)
    res = {}

    # properties = page.css('.product_specifications tr').map do |row|
    #   {
    #     row.at_css('th').text.strip => row.at_css('td').text.strip
    #   } rescue nil
    # end

    res[:name]        = page.at_css('.product-info h1').text.strip rescue nil
    return if res[:name].blank?
    res[:description] = page.at_css('#tab-description').inner_html.strip rescue ''
    res[:images]      = page.css('.image-additional a').map { |a| a['href'].to_s } rescue []
    res[:images] << page.at_css("#image")['src']
    # res[:properties]  = properties.select(&:present?)
    res[:url]         = @query
    # res[:vendor_code] = page.at_css('.kod > p').text.gsub('код товара ', '').strip
    res[:vendor]      = 'Grilly'
    res[:vendor_category]    = page.search(".breadcrumb a").last.text

    res

  end
end
