module PriceAutoupdateable
  def self.included(base)
    base.class_eval do

      private

      def self.price_list_format
        'xml'
      end

      def self.auto_update(merchant_id)
        merchant = Vendor::Merchant.find(merchant_id)
        tempfile = Tempfile.new("#{merchant_id}_price.xml")
        tempfile << get_fresh_pricelist
        tempfile.close
        merchant.update(format: price_list_format,
                        pricelist_state: 'Прайс добавлен в очередь после авто обновления',
                        pricelist_error: false)
        Vendor::Pricelist.async_import!(merchant.id, tempfile.path)
      end

    end
  end
end
