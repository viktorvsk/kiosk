class RanecoldParser < ::ActivePricelist::Base
  def transform

    @currency_order.each do |curr|
      if @product[curr].present? and @product[curr].to_i.ceil > 0
        @product['price'] = (@product[curr].to_i * @rates[curr].to_i).ceil
        if curr == 'rrc'
          @product['is_rrc'] = true
        else
          @product['price'] = (@product['price'] * (100 - @discount.to_i)/100).ceil
        end
        break
      end
    end
    unless @product['price'].blank? or @product['price'].to_i < 1
      @product['price'] = @product['price'] + 40
      @product['in_stock'] = !@not_in_stock.any? { |sign| @product['not_in_stock'] =~ /#{sign}/ }
      @product
    end

  end
end
