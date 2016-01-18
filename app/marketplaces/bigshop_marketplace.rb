class BigshopMarketplace < BasicMarketplace
  HOST = /bigs-shop/
  
  private
  
  def search_query
    "http://bigs-shop.com.ua/index.php?route=product/search&search=#{@query}"
  end
  
  def search_found_selector
    '.product-list'
  end

  def search_results_mapper(product)
    res = {}
    res[:name] = product.at_css('.name').text
    res[:url] = product.at_css('.name a')['href']
    res[:image] = product.at_css('.image a img')['data-src']
    price_node = product.at_css('.price')
    if price_node.present?
      res[:price] = price_node.text.scan(/\d/).join.to_i
    else
      res[:do_not_show] = true
      res[:price] = 'Нет в наличии'
    end
    res
  rescue
    nil
  end

  def scrape_properties_page
    url = @query
    html = Typhoeus.get(url, followlocation: true, verbose: false).body
    doc = Nokogiri::HTML(html)
    properties = []
    doc.search('tbody tr td').each_slice(2) do |name, value|
      properties << { name.text => value.text }
    end
    properties
  end

  def product_page_scraper(page)
    res = {}
    properties = scrape_properties_page
    res[:name] = page.at_css('#container h1').text
    res[:properties] = properties.select(&:present?)
    res[:url] = @query
    res[:name] = page.at_css('#container h1').text
    res[:images] = [page.at_css('#content img')['src']]
    res
  end
end
