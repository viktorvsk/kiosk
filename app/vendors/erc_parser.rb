class ErcParser < ::ActivePricelist::Base

  private

  def transform
    @currency_order.each do |curr|
      if @product[curr].present? && @product[curr].to_f.ceil > 0

        @product['price'] = (@product[curr].to_f * @rates[curr].to_f).ceil + @product['delivery_tax'].to_i

        if @product['monitor'] == '1'
          @product['price']   = @product['uah'].to_f.ceil
          @product['rrc']     = @product['price']
          @product['is_rrc']  = true
        else

          if (@product['ddp'] == '1') # && (curr == 'usd')
            @product['price'] = @product['usd'].to_f.ceil
          end

          @product['price'] = @product['price'] * ( (100 - @discount.to_i)/100 )

        end

        break
      end
    end
     if @product['price'].present? && @product['price'].to_f.ceil > 1
      @product['in_stock'] = !@not_in_stock.any? { |sign| @product['not_in_stock'] =~ /#{sign}/ }
    end

  end
end

