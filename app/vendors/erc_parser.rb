class ErcParser < ::Active::Pricelist::Base
  def transform

    @currency_order.each do |curr|
      if product[curr].present? and product[curr].to_i.ceil > 0

        if product['ddp'] == '1' and curr == 'usd'
          product['price'] = (product['usd'].to_i * @rates['uah'].to_i).ceil
        else
          product['price'] = (product[curr].to_i * @rates[curr].to_i).ceil
        end

        if product['monitor'] == '1'
          product['is_rrc'] = true
        else
          product['price'] = (product['price'] * (100 - @discount.to_i)/100).ceil
        end
        break
      end
    end
    product['in_stock'] = @in_stock.any?{ |sign| product['in_stock'] =~ /#{sign}/ }
    product

  end
end

