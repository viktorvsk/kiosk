class DclinkxmlParser < BaseParser
  include PriceAutoupdateable

  private

  def self.price_list_format
    'strict_xml'
  end

  def self.get_fresh_pricelist
    pricelist = Typhoeus.post("https://api.dclink.com.ua/api/GetPriceAll",
                  ssl_verifypeer: false,
                  body: {
                    login: 'evotex',
                    password: 'cv70ZVhW'
                  }).body.force_encoding('windows-1251').encode("utf-8")
    remove_price_by_pricetype(pricelist)
  end

  def self.remove_price_by_pricetype(pricelist)
    pricelist = Nokogiri::XML(pricelist.force_encoding('UTF-8'), nil, 'UTF-8')
    pricelist.search('Product').each do |row|
      if row.search('PriceType').text == 'USD'
        row.search("RetailPriceUAH").remove
      elsif row.search('PriceType').text == 'UAH'
        row.search("PriceUSD").remove
      end
    end
    pricelist.to_s
  end

  # def transform
  #   @currency_order.each do |curr|
  #     if @product[curr].to_f.ceil > 0
  #       @product['price'] = @product[curr].to_f
  #       if curr == 'rrc'
  #         @product['is_rrc'] = true
  #       else
  #         @product['price'] = (@product['price'].to_f * @rates[curr] * (100 - @discount.to_i) / 100).ceil
  #       end
  #       break
  #     end
  #   end
  #   @product['price'] += @product['delivery_tax'].to_i if !@product['is_rrc'] && (@product['price'].to_f.ceil > 0)
  #   @product['in_stock'] = !@not_in_stock.any? { |sign| @product['not_in_stock'] =~ /#{sign}/ }
  # end

  def transform
    @currency_order.each do |curr|
      if @product[curr].to_f.ceil > 0
        @product['price'] = @product[curr].to_f
        if curr == 'rrc'
          @product['is_rrc'] = true
        else
          @product['is_rrc'] = false
          rate = if @product['name'] =~ /ddp/i && curr == 'usd'
                   @dclink_ddp_rate.to_f
                 else
                   @rates[curr].to_f
                 end
          @product['price'] = (@product[curr].to_f * rate * (100 - @discount.to_i) / 100).ceil
        end
        break
      end
    end
    @product['price'] = @product['price'].to_f.ceil
    @product['price'] += @product['delivery_tax'].to_i if !@product['is_rrc'] && (@product['price'].to_f.ceil > 0)
    @product['in_stock'] = !@not_in_stock.any? { |sign| @product['stock_dclink'] == sign }
  end
end
