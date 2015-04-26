class ErcMarketplace < BasicMarketplace
  HOST = /erc/

  private

  def search_query
    "http://www.erc.ua/ru/search/#{@query}"
  end

  def search_found_selector
    '.ware'
  end

  def search_results_mapper(product)
    res = {}
    res[:image] = nil
    res[:name]  = product.at_css('a').text.strip
    res[:url]   = URI.join('http://erc.ua', product.at_css('a')['href']).to_s
    res[:price] = product.parent.at_css(".price").text.strip.split(',')[0].scan(/\d+/).join rescue 'Нет в наличии'
    res
  rescue
    nil
  end

  def product_page_scraper(page)
    res = {}
    properties = page.css('.vido_frame_properties_table tr').map do |row|
      {
        row.css('td')[0].text.strip => row.css('td')[1].text.strip
      } rescue nil
    end
    res[:name]        = page.at_css('#cpContent_divTitle').inner_html.split('<br>')[0].gsub(/^.+: /, '') rescue page.at_css('#cpContent_divTitle').try(:text)
    res[:description] = page.at_css('#tab_properties_desc').inner_html.strip rescue ''
    res[:images]      = page.css('.vido_frame_big_gallery_container img').map { |i| URI.join('http://erc.ua', i['src']).to_s rescue nil }.compact rescue []
    res[:properties]  = properties.select(&:present?)
    res[:url]         = @query
    # res[:category]    = page.at_css('.cpContent_tbVnd_pnVnd_tvVnd_2.cpContent_tbVnd_pnVnd_tvVnd_4').text.strip
    res
  end
end
