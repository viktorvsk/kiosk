class RozetkaMarketplace < BasicMarketplace
  HOST = /rozetka/

  def search
    options = {proxy: "211.110.127.210:3128"}
    request = Typhoeus::Request.new(search_query, options)
    html = request.run.body
    doc = Nokogiri::HTML(html)
    @products = doc.search(search_found_selector).map { |product| search_results_mapper(product) }.first(24)
  end

  private

  def search_query
    "http://rozetka.com.ua/search/?section=%2F&text=#{@query}"
  end

  def search_found_selector
    '.g-i-list'
  end

  def search_results_mapper(product)
    res = {}
    res[:name]  = product.at_css('.g-i-list-title a').text.strip
    res[:url]   = product.at_css('.g-i-list-title a')['href']
    res[:image] = product.at_css('.g-i-list-img img')['src']
    price_node  = product.at_css('.g-price-uah')

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

  def product_page_scraper(page)
    res = {}
    properties = scrape_properties_page

    res[:name]        = page.at_css('h1.detail-title').try(:text).to_s.strip
    res[:description] = page.at_css('#short_text').inner_html.strip rescue ''
    res[:properties]  = properties.select(&:present?)
    res[:url]         = @query
    if URI.parse(@query).host =~ /bt/
      res[:images]    = page.css('.detail-img-thumbs-l-i-link').map { |a| a['href'] } rescue []
    end
    # res[:category]    = page.at_css('.producers h2').text.strip

    res

  end

  def scrape_properties_page
    url = "#{@query}tab=characteristics"
    html = Typhoeus.get(url, followlocation: true, verbose: false).body
    doc = Nokogiri::HTML(html)
    properties = doc.css('.pp-characteristics-tab-i').map do |row|
      {
        row.at_css('dt').text.strip => row.at_css('dd').text.strip
      } rescue nil
    end

    properties
  end
end
