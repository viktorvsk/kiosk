class RozetkaMarketplace < BasicMarketplace
  HOST = /rozetka/


  private

  def search_query
    "http://rozetka.com.ua/search/?section=%2F&text=#{@query}"
  end

  def search_found_selector
    '.g-i-list'
  end

  def search_results_mapper(product)
    res = {
      name: product.at_css('.g-i-list-title a').text.strip,
      url: product.at_css('.g-i-list-title a')['href'],
      image: product.at_css('.g-i-list-img img')['src']
    }
    res[:price] = if (node = product.at_css('.g-price-uah')) && node.present?
      node.text.scan(/\d/).join.to_i
    else
      res[:do_not_show] = true
      'Нет в наличии'
    end
    res
  end

  def product_page_scraper(page)
    properties = page.css('.detail-chars-l-i').map do |row|
      {
        row.at_css('dt').text.strip => row.at_css('dd').text.strip
      }
    end
    {
      name: page.at_css('h1.detail-title').text.strip,
      description: page.at_css('#short_text').inner_html.strip,
      images: page.css('.detail-img-thumbs-l-i-link').map { |a| a['href'] },
      properties: properties,
      category: page.at_css('.producers h2').text.strip,
      url: @query
    }
  end
end
