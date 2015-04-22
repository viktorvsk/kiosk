class BrainMarketplace < BasicMarketplace
  HOST = /brain/


  private

  def search_query
    "http://brain.com.ua/search/#{@query}"
  end

  def search_found_selector
    '.photo_block'
  end

  def search_results_mapper(product)
    res = {
      name: product.at_css('.photo_block_headline a').text.strip,
      url: URI.join('http://brain.com.ua', product.at_css('.photo_block_headline a')['href']).to_s,
      image: URI.join('http://brain.com.ua', product.at_css('.photo img')['src']).to_s
    }
    res[:price] = if (node = product.at_css('.prise')) && node.present?
      node.text.to_i
    else
      res[:do_not_show] = false
      'Нет в наличии'
    end
    res
  end

  def product_page_scraper(page)
    properties = page.css('.product_specifications tr').map do |row|
      {
        row.at_css('th').text.strip => row.at_css('td').text.strip
      }
    end
    {
      name: page.at_css('h1').text.strip,
      description: page.at_css('.description').inner_html.strip,
      images: page.css('.thumbs_list a').map { |a| URI.join('http://brain.com.ua', a['href']).to_s },
      properties: properties,
      category: page.at_css('.crumbs a')[1].text.strip,
      url: @query
    }
  end
end
