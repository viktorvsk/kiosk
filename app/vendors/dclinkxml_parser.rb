class DclinkxmlParser < ::ActivePricelist::Base

  def self.auto_update(merchant_id)
    merchant = Vendor::Merchant.find(merchant_id)
    response = Typhoeus.post("https://opt.dclink.com.ua/xml.htm",
      body: {
        login: 'evotex',
        passw: 'cv70ZVhW',
        action: 'price',
        storage: 0,
        type: 0
        })
    tempfile = Tempfile.new("#{merchant_id}_price.xml")
    tempfile << response
    tempfile.close

    merchant.update(format: 'xml')
    Vendor::Pricelist.async_import!(merchant.id, tempfile.path)
    merchant.update(pricelist_state: 'Прайс в очереди', pricelist_error: false)

  end

end
