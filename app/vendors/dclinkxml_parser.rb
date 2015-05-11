class DclinkxmlParser < ::ActivePricelist::Base
  include PriceAutoupdateable

  private

  def self.get_fresh_pricelist
    Typhoeus.post("https://opt.dclink.com.ua/xml.htm",
      body: {
        login: 'evotex',
        passw: 'cv70ZVhW',
        action: 'price',
        storage: 0,
        type: 0
        }).body
  end

end
