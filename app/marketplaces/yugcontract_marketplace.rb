class YugcontractMarketplace < BasicMarketplace
  HOST = /yugcontract/


  private

  def search_query
    "http://yugcontract.ua/search/?q=#{@query}"
  end

  def search_found_selector
    '.cat-item'
  end

  def search_results_mapper(product)
    res = {
      name: product.at_css('em').text.strip,
      url: URI.join('http://yugcontract.ua', product.at_css('a')['href']).to_s,
      image: URI.join('http://yugcontract.ua', product.at_css('img')['src']).to_s,
      price: 1
    }
  end

  def product_page_scraper(page)
    properties = page.css('.properties-table tr').map do |row|
      {
        row.at_css('.prop').text.strip => row.at_css('.val').text.strip
      }
    end
    {
      name: page.at_css('h1').text.strip,
      description: '',
      images: page.css('#images-list a').map { |a| URI.join('http://yugcontract.ua', a['href']).to_s },
      properties: properties,
      category: page.at_css('.cat-menu .level1 a.active').text.strip,
      url: @query
    }
  end
end
