class DefaultParser < ::ActivePricelist::Base

  private

  def transform
    @currency_order.each do |curr|
      if @product[curr].to_f.ceil > 0
        @product['price'] = @product[curr].to_f.ceil + @product['delivery_tax'].to_i
        if curr == 'rrc'
          @product['is_rrc'] = true
        else
          @product['price'] = (@product['price'].to_f * @rates[curr] * (100 - @discount.to_i) / 100).ceil
        end
        break
      end
    end
    @product['in_stock'] = !@not_in_stock.any? { |sign| @product['not_in_stock'] =~ /#{sign}/ }
  end
end
