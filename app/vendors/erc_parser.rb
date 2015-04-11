class ErcParser < ::ActivePricelist::Base
  def transform

    @currency_order.each do |curr|
      if @product[curr].present? and @product[curr].to_f.ceil > 0

        if @product['ddp'] == '1' and curr == 'usd'
          @product['price'] = (@product['usd'].to_f * @rates['uah'].to_f).ceil
        else
          @product['price'] = (@product[curr].to_f * @rates[curr].to_f).ceil
        end

        if @product['monitor'] == '1'
          @product['is_rrc'] = true
        else
          @product['price'] = (@product['price'].to_f * (100 - @discount.to_i)/100).ceil
        end
        break
      end
    end
     unless @product['price'].blank? or @product['price'].to_f.ceil < 1
      @product['in_stock'] = !@not_in_stock.any? { |sign| @product['not_in_stock'] =~ /#{sign}/ }
    end

  end
end

