class BaseParser
    attr_reader :products, :xml
    attr_accessor :file,    :format,    :encoding, :start,
                  :columns, :rates,     :currency_order, :required,
                  :not_in_stock, :discount, :xslt

    def initialize(opts = {})
      @file       = opts['file']
      @format     = opts['format']
      @encoding   = opts['encoding']
      @columns    = opts['columns']
      @start      = opts['start']

      @dclink_ddp_rate = opts['dclink_ddp']

      @rates            = opts['rates']
      @currency_order   = opts['currency_order'] || %w(rrc uah usd eur)
      @required         = opts['required']       || %w(name)
      @not_in_stock     = opts['not_in_stock']   || ["-","Нет","нет","нет в наличии","ожидается",'\+/-',"в пути","резерв","доп.склад","в резервах","ждем","заказ","Ожидаем","поштучно","под заказ","Ожидается"]
      @discount         = opts['discount']       || 0
      @products         = []
      yield self if block_given?
    end

    def perform
      check_settings
      parse
      self
    end

    def reader_settings
      @reader_settings  ||= {
        'file'      => @file,
        'format'    => @format,
        'encoding'  => @encoding,
        'columns'   => @columns,
        'start'     => @start
      }
    end

    private

      def parse
        price_list = PricelistFormatReader.new(reader_settings)
        price_list.parse!
        price_list.rows.each do |row|
          @product = row
          transform
          products << @product if valid_product?
        end
      end

      def check_settings
        currency_order_is_valid = %w(rrc uah usd eur).all? { |curr| @currency_order.include?(curr) }
        currency_rate_is_valid  = @currency_order.all? { |curr| @rates[curr].present? }

        error = if !currency_order_is_valid
          'Invalid currency order'
        elsif !currency_rate_is_valid
          "Currency was set without rate: rates: #@rates, currencies: #@currency_order"
        end

        fail StandardError, error if error.present?
      end

      def transform
        # @currency_order.each do |curr|
        #   if @product[curr].to_f.ceil > 0
        #     @product['price'] = @product[curr].to_f.ceil + @product['delivery_tax'].to_i
        #     if curr == 'rrc'
        #       @product['is_rrc'] = true
        #     else
        #       @product['price'] = (@product['price'].to_f * @rates[curr] * (100 - @discount.to_i) / 100).ceil
        #     end
        #     break
        #   end
        # end
        # @product['in_stock'] = !@not_in_stock.any? { |sign| @product['not_in_stock'] =~ /#{sign}/ }
      end

      def valid_product?
        !@required.any? { |k| @product[k].blank? } &&
          @product['price'].present? &&
          @product['price'].to_f.ceil > 0
      end

  end
