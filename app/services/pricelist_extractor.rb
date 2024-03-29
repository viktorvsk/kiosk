require 'csv'

class PricelistExtractor
  @queue = :common

  REAL_ATTRIBUTES = %w(uah usd eur rrc in_stock_kharkov in_stock_kiev model brand category warranty name price in_stock is_rrc articul vendor_merchant_id).map(&:freeze).freeze
  CSV_COLUMNS = %w(articul name price in_stock vendor_merchant_id catalog_product_id created_at updated_at info is_rrc).join(',').freeze

  class << self
    def perform(merchant_id)
      new(merchant_id).extract!
    end
  end

  def initialize(merchant_id)
    @merchant       = Vendor::Merchant.find(merchant_id)
    @settings       = @merchant.to_activepricelist
    @parser_class   = @merchant.parser_class.presence || 'Default'
    @csv_path       = Rails.root.join('tmp',"products_to_create_#{merchant_id}.csv")
    @update_sql     = ''
  end

  def async_extract!
    Resque.enqueue(self.class, @merchant.id)
  end

  def extract!
    @init_time = Time.now
    process_new_pricelist
    group_products_articuls
    compose_update_sql
    compose_create_csv
    write_changes_to_db
    notify('Пересчитывается цена товаров')
    @merchant.catalog_products.recount
    puts Time.now.to_i - @init_time.to_i
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
      pricelist = "#{@parser_class}Parser".constantize.new(@settings).perform
      @products = Hash[pricelist.products.map { |p| [p['articul'], p] } ]
    end

    def group_products_articuls
      notify('Новый прайслист сравнивается со старым')
      @new_articuls = @products.keys
      @existing_articuls = @merchant.products.pluck(:articul)
      @to_update_articuls = @new_articuls & @existing_articuls
      @to_create_articuls = @new_articuls - @to_update_articuls

      # Vendor Products present in current catalog but absent in currently uploaded Pricelist
      @existing_products = @merchant.products.select(:articul).where.not(vendor_products: { articul: @new_articuls })
      @to_destroy = @existing_products.where(catalog_product_id: nil)
      @to_deactivate = @existing_products.where.not(catalog_product_id: nil)

      @to_update = @merchant.products.where(vendor_products: { articul: @to_update_articuls })
    end

    def compose_update_sql
      notify('Находятся прайсы, которые нужно обновить')
      @to_update.find_each(batch_size: 1000) do |old_product|
        new_product = @products[old_product.articul.to_s]
        info_attrs = Vendor::Product.new(new_product.slice(*REAL_ATTRIBUTES)).info.to_json
        s = %(
          UPDATE "vendor_products" SET
            "price" = #{new_product['price']},
            "name" = $string$#{new_product['name']}$string$,
            "is_rrc" = #{new_product['is_rrc']},
            "in_stock" = #{new_product['in_stock']},
            "info" = $json$#{info_attrs}$json$
          WHERE "articul" = '#{new_product['articul']}' AND "vendor_merchant_id" = '#{@merchant.id}';\n)
        @update_sql << s
      end
    end

    def compose_create_csv
      notify('Находятся прайсы, которые нужно создать')
      CSV.open(@csv_path, "wb") do |csv|
        @to_create_articuls.each do |art|
          p = @products[art]
          attrs = p.slice( *REAL_ATTRIBUTES )
          attrs['vendor_merchant_id'] = @merchant.id
          attrs['current_price'] = true
          csv << Vendor::Product.new(attrs).to_csv
        end
      end
    end

    def write_changes_to_db
      notify('Применяются изменения')
      ActiveRecord::Base.transaction do
        ActiveRecord::Base.connection.execute("COPY vendor_products(#{CSV_COLUMNS}) FROM '#{@csv_path}' WITH(FORMAT csv);")
        ActiveRecord::Base.connection.execute(@update_sql)
        @to_destroy.delete_all
        @to_deactivate.deactivate
        @to_update.activate
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
