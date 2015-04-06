require 'nokogiri'
require 'open-uri'

class BasicMarketplace
  attr_reader :products
  def initialize(query)
    @query = query
  end

  def search
    search_results = open(search_query)
    html = search_results.read
    doc = Nokogiri::HTML(html)
    @products = doc.search(search_found_selector).map { |product| search_results_mapper(product) }
  end

  def scrape
    doc = Nokogiri::HTML(open(@query).read)
    product_page_scraper(doc)
  end

  private

  def search_query
  end

  def search_found_selector
  end

  def search_results_mapper(product)
  end

  def product_page_scraper(page)
  end


end
