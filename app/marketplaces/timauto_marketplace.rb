class TimautoMarketplace < BasicMarketplace
  HOST = /timauto/

  def initialize(query)
    query = query.encode('cp1251')
    super
  end
    
  private
  
  def search_query
    "http://timauto.com.ua/search/index.php?s_str=#{@query}"
  end

  def search_found_selector
    '.products-item'
  end

  def search_results_mapper(product)
    res = {}
    url = 'http://timauto.com.ua/'
    res[:name] = product.at_css('.products-name a').text
    res[:url] = url + product.at_css('.products-name a')['href']
    res[:image] = url + product.at_css('img')['src']
    if price_node = product.at_css('.products-price span')
      res[:price] = price_node.text.scan(/\d/).join.to_i
    else
      res[:do_not_show] = true
      res[:price] = 'Нет в наличии'
    end
    res
  rescue
    nil
  end

  #TODO: решить что делать с разной версткой
  def scrape_properties_page
    url = @query
    html = Typhoeus.get(url, followlocation: true, verbose: false).body
    doc = Nokogiri::HTML(html)
    properties = []
    properties = properties.search('.product-content .tabcontent-off li').map do |property|
      property_pair = property.text.split(':')
      { property_pair.first => property_pair.last }
    end
    properties
  end

  def product_page_scraper(page)
    res = {}
    properties = scrape_properties_page
    res[:name] = page.at_css('.csidebar .blockname').text
    res[:properties] = properties.select(&:present?)
    res[:url] = @query
    res[:images] = ["http://timauto.com.ua/#{page.at_css('.fleft .product-image')['src']}"]
    res
  end
end
