require 'csv'

module Vendor
  class Pricelist
    @queue = :pricelist_import
    REAL_ATTRIBUTES = %w(uah usd eur rrc in_stock_kharkov in_stock_kiev model brand category warranty name price in_stock is_rrc articul vendor_merchant_id).map(&:freeze).freeze
    CSV_COLUMNS = %w(articul name price in_stock vendor_merchant_id catalog_product_id created_at updated_at info is_rrc).join(',').freeze

    class << self
      def async_import!(merchant_id, file_path)
        Resque.enqueue(Vendor::Pricelist, merchant_id, file_path)
      end

      def perform(merchant_id, file_path)
        Vendor::Pricelist.new(merchant_id, file_path).import!
      end
    end

    def initialize(merchant_id, file_path)
      @file_path      = file_path
      @merchant       = Vendor::Merchant.find(merchant_id)
      @settings       = @merchant.to_activepricelist
      @parser_class   = @merchant.parser_class.presence || 'Default'
      @csv_path       = Rails.root.join('tmp',"products_to_create_#{merchant_id}.csv")
      @update_sql     = []
      @to_destroy     = []
      @to_deactivate  = []
    end

    def import!
      @init_time = Time.now
      process_new_pricelist
      group_products_articuls
      compose_update_sql
      compose_create_csv
      write_changes_to_db
      notify('Пересчитывается цена товаров')
      @merchant.catalog_products.recount
      notify
      true
    rescue => e
      err = %(Произошла ошибка (#{e.class}): #{e.message}\n#{e.backtrace.first(5).join("\n")})
      notify(err, true)
      false
    ensure
      FileUtils.rm @csv_path if File.file? @csv_path
      FileUtils.rm @merchant.pricelist_path if File.file? @merchant.pricelist_path
    end

  private

    def process_new_pricelist
      notify('Прайслист обрабатывается')
      if File.file?(@file_path)
        @file = File.new(@file_path)
        File.open(@merchant.pricelist_path, 'wb'){ |f| f.puts @file.read }
      else
        notify("Ошибка загрузки файла:\n #{@file_path}", true)
        return
      end
      pricelist = "#{@parser_class}Parser".constantize.new(@settings).perform
      @products = pricelist.products
    end

    def group_products_articuls
      notify('Новый прайслист сравнивается со старым')
      @existing_products = @merchant.products.select(:articul, :catalog_product_id)
      @existing_articuls = @existing_products.map { |p| p['articul'] }
      @new_articuls = @products.map { |p| p['articul'] }
      @existing_products.each do |p|
        next if p['articul'].in?(@new_articuls)
        if p['catalog_product_id'].nil?
          @to_destroy << p['articul']
        else
          @to_deactivate << p['articul']
        end
      end
      @to_update_articuls = @new_articuls & @existing_articuls
      @to_create_articuls = @new_articuls - @to_update_articuls
    end

    def compose_update_sql
      notify('Находятся прайсы, которые нужно обновить')
      @merchant.products.where(vendor_products: { articul: @to_update_articuls }).each do |p|
        info_attrs = p.info.to_json
        @update_sql << %(
          UPDATE "vendor_products" SET
            "price" = #{p['price']},
            "is_rrc" = #{p['is_rrc']},
            "in_stock" = #{p['in_stock']},
            "info" = $json$#{info_attrs}$json$
          WHERE "articul" = '#{p['articul']}' AND "vendor_merchant_id" = '#{@merchant.id}';)
      end
    end

    def compose_create_csv
      notify('Находятся прайсы, которые нужно создать')
      CSV.open(@csv_path, "wb") do |csv|
        @products.select { |p| p['articul'].in?(@to_create_articuls) }.each do |p|
          attrs = p.slice( *REAL_ATTRIBUTES )
          attrs['vendor_merchant_id'] = @merchant.id
          csv << Vendor::Product.new(attrs).to_csv
        end
      end
    end

    def write_changes_to_db
      notify('Применяются изменения')
      ActiveRecord::Base.transaction do
        ActiveRecord::Base.connection.execute("COPY vendor_products(#{CSV_COLUMNS}) FROM '#{@csv_path}' WITH(FORMAT csv);")
        ActiveRecord::Base.connection.execute(@update_sql.join("\n"))
        @merchant.products.where(vendor_products: { articul: @to_destroy }).delete_all
        @merchant.products.where(vendor_products: { articul: @to_deactivate }).deactivate
        @merchant.products.where(vendor_products: { articul: @new_articuls }).activate
      end
    end

    def notify(message = nil, error = false)
      t = Time.now.to_i - @init_time.to_i
      if message.present?
        @merchant.update(pricelist_state: "[#{t} с]#{message}", pricelist_error: error.to_s)
      else
        @merchant.update(pricelist_state: nil, pricelist_error: false, last_price_date: Time.now.strftime("%e.%m %X") )
      end
    end
  end
end
