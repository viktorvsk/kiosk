module PriceAutoupdateable
  def self.included(base)
    base.class_eval do

      private

      def self.auto_update(merchant_id)
        merchant = Vendor::Merchant.find(merchant_id)
        tempfile = Tempfile.new("#{merchant_id}_price.xml")
        tempfile << get_fresh_pricelist
        tempfile.close
        merchant.update(format: 'xml')
        Vendor::Pricelist.async_import!(merchant.id, tempfile.path)
        merchant.update(pricelist_state: 'Прайс в очереди', pricelist_error: false)
      end

    end
  end
end
