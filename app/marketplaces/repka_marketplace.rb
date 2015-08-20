class RepkaMarketplace < BasicMarketplace
  HOST = /repka/

  private

  def search_query
    "https://repka.ua/search/?q=#{@query}"
  end

  def search_found_selector
    '.cat-list-item'
  end

  def search_results_mapper(product)
    res = {}
    res[:name]  = product.at_css('.title a').text.strip
    res[:url]   = URI.join('https://repka.ua', product.at_css('.title a')['href']).to_s
    res[:image] = URI.join('https://repka.ua', product.at_css('.image img')['data-original']).to_s
    price_node  = product.at_css('.price-uah span')

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

    properties = page.css('#table-char tr').map do |row|
      {
        row.css('td')[0].text.strip => row.css('td')[1].text.strip
      } rescue nil
    end

    res[:name]        = page.at_css('h1').text.strip
    res[:description] = page.at_css('#tab_block_main').inner_html.strip rescue ''
    res[:images]      = page.css('ul.sc_box img').map { |img| URI.join('https://repka.ua', img['data-detsrc']).to_s } rescue []
    res[:properties]  = properties.select(&:present?)
    res[:url]         = @query
    res[:vendor_code] = page.at_css('.code span').text.strip
    res[:vendor_category]    = page.at_css('.back-to-catalog a').text.strip

    res

  end
end
