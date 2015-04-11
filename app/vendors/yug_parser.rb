class YugParser < ::ActivePricelist::Base
  def transform

    @currency_order.each do |curr|
      if @product[curr].present? and @product[curr].to_f.ceil > 0
        @product['price'] = (@product[curr].to_f * @rates[curr].to_f).ceil
        if curr == 'rrc'
          @product['is_rrc'] = true
        else
          @product['price'] = (@product['price'].to_f * (100 - @discount.to_i)/100).ceil
        end
        break
      end
    end

    unless @product['price'].blank? or @product['price'].to_f.ceil < 1
      @product['in_stock_kharkov'] = !@not_in_stock.any?{ |sign| @product['stock_kharkov'] =~ /#{sign}/ }
      @product['in_stock_kiev']    = !@not_in_stock.any?{ |sign| @product['stock_kiev'] =~ /#{sign}/ }
      @product['in_stock']         = @product['in_stock_kharkov'] || @product['in_stock_kiev']
    end


  end
end
