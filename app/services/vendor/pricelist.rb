require 'csv'

module Vendor
  class Pricelist
    @queue            = :pricelist_import
    UPDATE_ATTRIBUTES = %w(uah usd eur rrc in_stock in_stock_kharkov in_stock_kiev price is_rrc)
    REAL_ATTRIBUTES   = %w(uah usd eur rrc in_stock_kharkov in_stock_kiev model brand category warranty name price in_stock is_rrc articul vendor_merchant_id)
    CSV_COLUMNS       = %w(articul name price in_stock vendor_merchant_id catalog_product_id created_at updated_at info is_rrc).join(',').freeze

    class << self
      def async_import!(merchant_id, file_path)
        Resque.enqueue(::Vendor::Pricelist, merchant_id, file_path)
      end

      def perform(merchant_id, file_path)
        ::Vendor::Pricelist.new(merchant_id, file_path).import!
      end

    end

    def initialize(merchant_id, file_path)
      @file         = File.new(file_path)
      @merchant     = ::Vendor::Merchant.find(merchant_id)
      @settings     = @merchant.to_activepricelist
      @parser_class = @merchant.parser_class.presence || 'Default'
    end

    def import!
      notify('Загружается прайслист')
      upload_pricelist
      notify('Прайслист обрабатывается')
      parse_pricelist
      notify('Удаляются товары, которых нет в новом прайслисте')
      # @products_names    = @merchant.products.pluck('vendor_products.name')
      @products_articuls = @merchant.products.pluck('vendor_products.articul')
      delete_not_in_pricelist
      batch_create_or_update
      notify('Привязываются товары')
      # Binder.perform
      notify('Пересчитывается цена товаров')
      @merchant.catalog_products.recount
      notify
      true
    rescue Exception => e
      err = %(Произошла ошибка (#{e.class}): #{e.message}\n#{e.backtrace.first(5).join("\n")})
      notify(err, true)
      false
    ensure
      FileUtils.rm @merchant.pricelist_path if File.file? @merchant.pricelist_path
    end

  private

    def notify(message = nil, error = false)
      if message.present?
        @merchant.update(pricelist_state: message, pricelist_error: error.to_s)
      else
        @merchant.update(pricelist_state: nil, pricelist_error: false, last_price_date: Time.now.strftime("%e.%m %X") )
      end
    end

    def delete_not_in_pricelist
      @to_delete = @products_articuls - @products.map{ |p| p['articul'] }
      @merchant
        .products
        .unbound
        .where(vendor_products: { articul: @to_delete })
        .delete_all
      @merchant
        .products
        .bound
        .where(vendor_products: { articul: @to_delete })
        .deactivate
    end

    def upload_pricelist
       File.open(@merchant.pricelist_path, 'wb'){ |f| f.puts @file.read }
    end

    def parse_pricelist
      @pricelist ||= "#{@parser_class}Parser".constantize.new(@settings).perform
      @products = @pricelist.products
      @pricelist
    end

    def batch_create_or_update
      from_hash_to_update
      from_hash_to_create
      notify('Обновляются существующие прайсы')
      batch_update( @to_update )
      notify('Создаются новые прайсы')
      batch_create( @to_create )
      actual_products = @to_create_articuls.try(:count).to_i + @to_update_articuls.try(:count).to_i
      Vendor::Product.where(id: actual_products).activate
    end

    def batch_update( products )
      sql = products.compact.map do |p|
        info_attrs = p.info.to_json
        expression = %(UPDATE "vendor_products" SET
          "price" = #{p['price']},
          "is_rrc" = #{p['is_rrc']},
          "in_stock" = #{p['in_stock']},
          "info" = $json$#{info_attrs}$json$ WHERE "articul" = '#{p['articul']}';)
      end.join
      ActiveRecord::Base.connection.execute(sql)
    end

    def batch_create( products )
      @to_create_articuls = products.map(&:id)
      return if products.empty?
      csv_path = Rails.root.join('tmp','products_to_create.csv')
      ::CSV.open(csv_path, "wb") do |csv|
        products.each do |product|
          csv << product.to_csv
        end
      end
      begin
        ActiveRecord::Base.connection.execute("COPY vendor_products(#{CSV_COLUMNS}) FROM '#{csv_path}' WITH(FORMAT csv);")
      ensure
        FileUtils.rm csv_path
      end
    end

    def from_hash_to_update
      articuls             = @products.map{ |p| p['articul'] }
      @to_update           = @merchant.products.where(articul: articuls).all
      @to_update_articuls  = @to_update.pluck(:articul)
      @to_update = @to_update.map do |product|
        new_product = @products.detect{ |p| p['articul'] == product.articul }
        # next if product['price'].to_i == new_product['price'].to_i
        new_product_attributes = new_product.slice( *UPDATE_ATTRIBUTES )
        new_product_attributes.each do |k, v|
          product.send("#{k}=", v)
        end

        product
      end
    end

    def from_hash_to_create
      @to_create = @products.reject{ |p| p['articul'].in?( @to_update_articuls ) }
      @to_create.each{ |p| p['vendor_merchant_id'] = @merchant.id  }
      @to_create.map!{ |p| ::Vendor::Product.new(p.slice( *REAL_ATTRIBUTES )) }
      # @TODO manual validations
      # @to_create.uniq!{ |p| p.name }
      @to_create.uniq!{ |p| p.articul }
      @to_create.reject!{ |p| p.articul.blank? || p.articul.in?(@products_articuls) } # or p.name.in?(@products_names)
    end

  end
end
