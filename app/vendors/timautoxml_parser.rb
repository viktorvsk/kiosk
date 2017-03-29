class TimautoxmlParser < BaseParser
  include PriceAutoupdateable

  private

  class << self
    def get_fresh_pricelist
      pricelist = Typhoeus.get('https://timauto.com.ua/tools/ym-mopt.php').body.force_encoding('windows-1251').encode('utf-8')
      transfer_id_from_attributes(pricelist)
    end

    def transfer_id_from_attributes(pricelist)
      doc = Nokogiri::HTML(pricelist)
      doc.search('offer').each do |product|
        product << product_id(product, doc)
      end
      doc.to_s
    end

    def product_id(product, doc)
      id = product.attributes['id'].value
      node = Nokogiri::XML::Node.new('id', doc)
      node.tap{ |x| x.content = id }
    end

    # def product_available(product, doc)
    #   available_state = product.attributes['available'].value
    #   node = Nokogiri::XML::Node.new('available', doc)
    #   node.tap{ |x| x.content = available_state }
    # end
  end

  def transform
    @currency_order.each do |curr|
      if @product[curr].to_f.ceil > 0
        @product['price'] = @product[curr].to_f
        if curr == 'rrc'
          @product['is_rrc'] = true
        else
          @product['is_rrc'] = false
          @product['price'] = (@product['price'].to_f * @rates[curr].to_f * (100 - @discount.to_i) / 100).ceil
        end
        break
      end
    end
    @product['price'] = @product['price'].to_f.ceil
    @product['price'] += @product['delivery_tax'].to_i if !@product['is_rrc'] && (@product['price'].to_f.ceil > 0)
    @product['in_stock'] = !@not_in_stock.any? { |sign| @product['not_in_stock'] =~ /#{sign}/ }
  end
end
