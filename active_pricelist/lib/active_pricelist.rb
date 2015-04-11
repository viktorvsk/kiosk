require 'nokogiri'
require 'simple_xlsx_reader'
require 'roo'
require 'active_support'
require 'active_support/core_ext'

require 'active_pricelist/version'
require 'active_pricelist/errors'
require 'active_pricelist/reader'
require 'active_pricelist/writer'
require 'active_pricelist/base'

#--
# ActivePricelist unifies different pricelists
# formats from suppliers, allows calculate price and InStock
# parameters using specific rules.
#++
module ActivePricelist
  def self.root
    Pathname.new(File.expand_path '../..', __FILE__)
  end
end
