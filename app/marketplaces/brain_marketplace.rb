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
    res = {}
    res[:name]  = product.at_css('.photo_block_headline a').text.strip
    res[:url]   = URI.join('http://brain.com.ua', product.at_css('.photo_block_headline a')['href']).to_s
    res[:image] = URI.join('http://brain.com.ua', product.at_css('.photo img')['src']).to_s
    price_node  = product.at_css('.prise')

    if price_node.present?
      res[:price] = price_node.text.to_i
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

    properties = page.css('.product_specifications tr').map do |row|
      {
        row.at_css('th').text.strip => row.at_css('td').text.strip
      } rescue nil
    end

    res[:name]        = page.at_css('h1').text.strip
    res[:description] = page.at_css('.description').inner_html.strip rescue ''
    res[:images]      = page.css('.thumbs_list a').map { |a| URI.join('http://brain.com.ua', a['href']).to_s } rescue []
    res[:properties]  = properties.select(&:present?)
    res[:url]         = @query
    res[:vendor_code] = page.at_css('.kod > p').text.gsub('код товара ', '').strip
    res[:vendor_category]    = page.css('.crumbs a')[1].text.strip

    res

  end
end
