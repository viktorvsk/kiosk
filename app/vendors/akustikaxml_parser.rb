class AkustikaxmlParser < ::ActivePricelist::Base
  include PriceAutoupdateable

  private

  def self.get_fresh_pricelist
    Typhoeus.get("http://xmlex.kin.dp.ua/21ev/priceA00002851.xml").body.force_encoding("UTF-8")
  end

  def transform
    @currency_order.each do |curr|
      if @product[curr].to_f.ceil > 0
        @product['price'] = @product[curr].to_f
        if curr == 'rrc'
          @product['is_rrc'] = true
        else
          @product['price'] = (@product['price'].to_f * @rates[curr].to_f * (100 - @discount.to_i) / 100).ceil
        end
        break
      end
    end
    @product['price'] += @product['delivery_tax'].to_i if !@product['is_rrc'] && (@product['price'].to_f.ceil > 0)
    @product['in_stock'] = !@not_in_stock.any? { |sign| @product['not_in_stock'] =~ /#{sign}/ }
  end

end
