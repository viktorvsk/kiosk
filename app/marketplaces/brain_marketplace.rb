class BrainMarketplace < BasicMarketplace
  HOST = /brain/

  def search
    response = Typhoeus.get(search_query, followlocation: true, verbose: false)
    html = response.body
    doc = Nokogiri::HTML(html)
    if response.effective_url =~ /brain.com.ua\/category/
      product = doc.search(".goods-block--list .goods-block__item").first
      res = {}
      res[:name]        = product.at_css('a.goods-block__name').text.strip
      res[:url]         = URI.join('https://brain.com.ua', product.at_css('a.goods-block__name')['href']).to_s
      res[:image]       = URI.join('https://brain.com.ua', product.at_css('.goods-block__image img')['src']).to_s
      res[:price]       = product.at_css('.goods-block__price-new').text.strip.to_i
      @products = [res]
    else
      @products = doc.search(search_found_selector).map { |product| search_results_mapper(product) }.first(24)
    end
  end

  private

  def search_query
    "https://brain.com.ua/search?s=#{@query}"
  end

  def search_found_selector
    '.absolute_bg'
  end

  def search_results_mapper(product)
    res = {}
    res[:name]  = product.at_css('.name a').text.strip
    res[:url]   = URI.join('https://brain.com.ua', product.at_css('.name a')['href']).to_s
    res[:image] = URI.join('https://brain.com.ua', product.at_css('.img img')['src']).to_s
    price_node  = product.at_css('.price .number')

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

    properties = page.css(".specifications-list__item").map do |row|
      {
        row.xpath('.').first.xpath('./text()').text.strip => row.css('span').text.strip
      } rescue nil
    end


    res[:name]        = page.at_css('.good-card__title').text.strip
    res[:description] = page.at_css('.description-text').inner_html.strip rescue ''
    res[:images]      = page.css('.preview_slider img').map { |img| img['src'].gsub(/small/, 'big') } rescue []
    res[:properties]  = properties.select(&:present?)
    res[:url]         = @query
    res[:vendor_code] = page.at_css('.product-num__curr').text.strip
    res[:vendor_category]    = page.css('.breadcrumbs__list a').last.text.strip

    res

  end
end
