class AkustikaxmlParser < ::ActivePricelist::Base
  include PriceAutoupdateable

  private

  def self.get_fresh_pricelist
    Typhoeus.get("http://xmlex.kin.dp.ua/21ev/priceA00002851.xml").body.force_encoding("UTF-8")
  end

end
