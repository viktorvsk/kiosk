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
    res = {
      name: product.at_css('.title-box h3 a').text.strip,
      url: full_url(product.at_css('.title-box h3 a')['href']),
      image: full_url(product.at_css('.img-box img')['src'])
    }
    res[:price] = if (node = product.at_xpath("//span[@class='orng']/text()")) && node.present?
      node.text.scan(/\d/).join.to_i
    else
      'Нет в наличии'
    end
    res
  end

  def product_page_scraper(page)
    properties = page.css('#full-props-list tr').map do |row|
      next unless row.at_css('td').present?
      {
        row.at_css('th').text.strip => row.at_css('td').text.strip
      }
    end.compact
    {
      name: page.at_css('h1.title-main').text.strip,
      description: page.at_css('.description').try(:inner_html).to_s.strip,
      images: page.css('.hl-gallery-item').map { |i| full_url(i['src']) },
      properties: properties,
      category: page.at_css('.good-type').text.strip,
      url: @query
    }
  end

  def full_url(url)
    URI.join('http://hotline.ua', url).to_s
  end
end
