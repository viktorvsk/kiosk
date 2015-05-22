class DclinkxmlParser < ::ActivePricelist::Base
  include PriceAutoupdateable

  private

  def self.price_list_format
    'strict_xml'
  end

  def self.get_fresh_pricelist
    Typhoeus.post("https://opt.dclink.com.ua/xml.htm",
      body: {
        login: 'evotex',
        passw: 'cv70ZVhW',
        action: 'price',
        storage: 0,
        type: 0
        }).body.force_encoding('windows-1251').encode("utf-8")
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
          rate = if @product['name'] =~ /ddp/i
            @dclink_ddp_rate.to_f
          else
            @rates[curr].to_f
          end
          @product['price'] = (@product['usd'].to_f * rate * (100 - @discount.to_i) / 100).ceil
        end
        break
      end
    end
    @product['price'] = @product['price'].to_f.ceil
    @product['price'] += @product['delivery_tax'].to_i if !@product['is_rrc'] && (@product['price'].to_f.ceil > 0)
    @product['in_stock'] = !@not_in_stock.any? { |sign| @product['not_in_stock'] =~ /#{sign}/ }
  end


end
