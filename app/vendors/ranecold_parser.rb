class RanecoldParser < ::Active::Pricelist::Base
  def transform

    @currency_order.each do |curr|
      if product[curr].present? and product[curr].to_i.ceil > 0
        product['price'] = (product[curr].to_i * @rates[curr].to_i).ceil
        if curr == 'rrc'
          product['is_rrc'] = true
        else
          product['price'] = (product['price'] * (100 - @discount.to_i)/100).ceil
        end
        break
      end
    end
    product['price'] = product['price'] + 40
    product['in_stock'] = @in_stock.any?{ |sign| product['in_stock'] =~ /#{sign}/ }
    product

  end
end
