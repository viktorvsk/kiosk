module PriceAutoupdateable
  def self.included(base)
    base.class_eval do

      private

      def self.auto_update(merchant_id)
        merchant = Vendor::Merchant.find(merchant_id)
        tempfile = Tempfile.new("#{merchant_id}_price.xml")
        tempfile << get_fresh_pricelist
        tempfile.close
        merchant.update(format: price_list_format || 'xml')
        merchant.update(pricelist_state: 'Прайс в очереди', pricelist_error: false)
        Vendor::Pricelist.new(merchant.id, tempfile.path).import!
      end

    end
  end
end
