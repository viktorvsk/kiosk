class TechnotradeParser < ::ActivePricelist::Base
  def transform

    if @product['uah_1'].to_f.ceil > 0
        @product['uah'] = @product['uah_1']
    else
        @product['uah'] = @product['uah_2']
    end

    @currency_order.each do |curr|
      if @product[curr].present? and @product[curr].to_f.ceil > 0
        @product['price'] = (@product[curr].to_f * @rates[curr].to_f).ceil
        if curr == 'rrc'
          @product['is_rrc'] = true
        else
          @product['price'] = (@product['price'].to_f * (100 - @discount.to_f.ceil)/100).ceil
        end
        break
      end
    end

    unless @product['price'].blank? or @product['price'].to_f.ceil < 1
      @product['in_stock_kharkov']  = (@product['uah_1'].to_f.ceil > 0)
      @product['in_stock_kiev']     = (@product['uah_2'].to_f.ceil > 0)
      @product['in_stock']          = @product['in_stock_kharkov'] || @product['in_stock_kiev']
    end

  end

end
