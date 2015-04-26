class HotlineMarketplace < BasicMarketplace
  HOST = /hotline/

  private

  def search_query
    "http://hotline.ua/sr/?q=#{@query}"
  end

  def search_found_selector
    'ul.catalog > li'
  end

  def search_results_mapper(product)
    res = {}

    res[:name]  = product.at_css('.title-box h3 a').text.strip
    res[:url]   = full_url(product.at_css('.title-box h3 a')['href'])
    res[:image] = full_url(product.at_css('.img-box img')['src'])
    price_node  = product.at_xpath("//span[@class='orng']/text()")

    if price_node.present?
      res[:price] = price_node.text.scan(/\d/).join.to_i
    else
      res[:price] = 'Нет в наличии'
    end

    res
  rescue
    nil
  end

  def product_page_scraper(page)
    res = {}
    properties = page.css('#full-props-list tr').map do |row|
      next unless row.at_css('td').present?
      {
        row.at_css('th').text.strip => row.at_css('td').text.strip
      } rescue nil
    end.compact

    res[:name]        = page.at_css('h1.title-main').text.strip
    res[:description] = page.at_css('.description').try(:inner_html).to_s.strip
    res[:images]      = page.css('.hl-gallery-item').map { |i| full_url(i['src']) } rescue []
    res[:properties]  = properties.select(&:present?)
    res[:url]         = @query
    #res[:category]    = page.at_css('.good-type').text.strip

    res
  end

  def full_url(url)
    URI.join('http://hotline.ua', url).to_s
  end
end
