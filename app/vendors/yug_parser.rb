class YugParser < ::ActivePricelist::Base


  private

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

    @product['in_stock_kharkov'] = !@not_in_stock.any?{ |sign| @product['stock_kharkov'] =~ /#{sign}/ }
    @product['in_stock_kiev']    = !@not_in_stock.any?{ |sign| @product['stock_kiev'] =~ /#{sign}/ }
    @product['in_stock']         = @product['in_stock_kharkov'] || @product['in_stock_kiev']

  end
end
