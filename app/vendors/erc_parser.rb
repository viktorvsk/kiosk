class ErcParser < ::ActivePricelist::Base

  private

  def transform
    @currency_order.each do |curr|
      if @product[curr].present? && @product[curr].to_f.ceil > 0

        @product['price'] = (@product[curr].to_f * @rates[curr].to_f).ceil

        if @product['monitor'] == '1'
          @product['price']   = @product['uah'].to_f
          @product['rrc']     = @product['price']
          @product['is_rrc']  = true
        else
          @product['is_rrc'] = false
          if (@product['ddp'] == '1') # && (curr == 'usd')
            @product['price'] = @product['usd'].to_f.ceil
          end

          @product['price'] = @product['price'] * ( (100 - @discount.to_i)/100 )

        end

        break
      end
    end
    @product['price'] = @product['price'].ceil
    @product['price'] += @product['delivery_tax'].to_i if !@product['is_rrc'] && (@product['price'].to_f.ceil > 0)
    @product['in_stock'] = !@not_in_stock.any? { |sign| @product['not_in_stock'] =~ /#{sign}/ }

  end
end

