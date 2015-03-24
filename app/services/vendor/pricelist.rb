require 'csv'

module Vendor
  class Pricelist
    UPDATE_ATTRIBUTES = %w(uah usd eur rrc in_stock in_stock_kharkov in_stock_kiev price is_rrc)
    SELECT_ATTRIBUTES = %w( id articul price  )
    REAL_ATTRIBUTES   = %w(uah usd eur rrc in_stock_kharkov in_stock_kiev model brand category warranty name price in_stock is_rrc articul vendor_merchant_id)
    CSV_COLUMNS       = %w(articul name price in_stock vendor_merchant_id catalog_product_id created_at updated_at info is_rrc).join(',').freeze

    def initialize(merchant, file)
      @file         = file
      @merchant     = merchant
      @settings     = @merchant.to_activepricelist
      @parser_class = @merchant.parser_class.presence || 'Default'
    end

    def import!
      GC.enable
      GC.start
      upload_pricelist
      parse_pricelist
      GC.start
      @products_names    = @merchant.products.pluck('vendor_products.name')
      @products_articuls = @merchant.products.pluck('vendor_products.articul')
      delete_not_in_pricelist
      batch_create_or_update
      GC.start
      true
    end

  private

    def delete_not_in_pricelist
      @to_delete = @products_articuls - @products.map{ |p| p['articul'] }

      @merchant.
        products.
        unbound.
        where(vendor_products: { articul: @to_delete }).
        delete_all
      @merchant.
        products.
        bound.
        where(vendor_products: { articul: @to_delete }).
        deactivate
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
      batch_update( @to_update )
      GC.start
      batch_create( @to_create )
    end

    def batch_update( products )
      sql = products.compact.map do |p|
        attributes_to_update = []
        p.attributes.keys.select{ |q| q.in?(UPDATE_ATTRIBUTES) }.each do |att|
          next unless p[att].to_s.present?
          attributes_to_update << "#{att} = #{p[att]}"
        end
        attributes_to_update = attributes_to_update.join(", ")
        expression = "UPDATE vendor_products SET #{attributes_to_update} WHERE articul = '#{p['articul']}';"
      end.join
      ActiveRecord::Base.connection.execute(sql)
    end

    def batch_create( products )
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
        next if product['price'].to_i == new_product['price'].to_i
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
      @to_create.uniq!{ |p| p.name }
      @to_create.uniq!{ |p| p.articul }
      @to_create.reject!{ |p| p.articul.blank? or p.name.in?(@products_names) or p.articul.in?(@products_articuls) }
    end

  end
end
