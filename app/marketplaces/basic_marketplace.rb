require 'nokogiri'
require 'typhoeus'

class BasicMarketplace
  attr_reader :products

  def initialize(query)
    @query = URI.encode URI.decode query
  end

  class << self
    def find_by_url(url)
      active_marketplaces = Conf['marketplaces'].split.map{ |m| "#{m}Marketplace".classify }
      host = URI.parse(url.to_s.strip).host.to_s
      active_marketplaces.detect { |m| m.constantize::HOST =~ host }.constantize
    end

    def find_products_by_query(query)
      threads = []
      products = []
      active_marketplaces = Conf['marketplaces'].split.map{ |m| "#{m}Marketplace".classify }
      active_marketplaces.each do |marketplace|
        searcher = marketplace.constantize.new(query)
        threads << Thread.new do
          Timeout::timeout(5) do
            products << searcher.search
          end
        end
      end
      threads.each(&:join)
      products.flatten.compact
    end
  end

  def search
    html = Typhoeus.get(search_query, followlocation: true, verbose: false).body
    doc = Nokogiri::HTML(html)
    @products = doc.search(search_found_selector).map { |product| search_results_mapper(product) }.first(24)
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
