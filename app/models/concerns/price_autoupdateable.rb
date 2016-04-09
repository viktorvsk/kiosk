

module PriceAutoupdateable
  def self.included(base)
    base.class_eval do

      private

      def self.price_list_format
        'xml'
      end

      def self.auto_update(merchant_id)
        merchant = Vendor::Merchant.find(merchant_id)
        merchant.update(format: price_list_format,
                        pricelist_state: 'Прайс добавлен в очередь после авто обновления',
                        pricelist_error: false)
        File.open(merchant.pricelist_path, 'w') { |f| f.puts(get_fresh_pricelist) }
        PricelistExtractor.new(merchant.id).async_extract!
      end

    end
  end
end
