class PricelistFormatReader
    SUPPORTED_FORMATS = ['xml', 'strict_xml', 'xls', 'xlsx', 'csv'].freeze
    attr_reader :rows
    attr_accessor :file,        :format,      :encoding,
                  :start,       :columns,
                  :csv_headers, :csv_separator
    class << self
      def supported_format?(fmt)
        fmt.in? SUPPORTED_FORMATS
      end
    end

    def initialize(opts = {})
      self.columns        = opts['columns']        if opts['columns']
      self.format         = opts['format']         if opts['format']
      self.start          = opts['start']          if opts['start']
      self.file           = opts['file']           if opts['file']
      self.encoding       = opts['encoding']       || 'UTF-8'
      self.csv_headers    = opts['csv_headers']    || false
      self.csv_separator  = opts['csv_separator']  || '|'
      @rows               = []
      yield self if block_given?
    end

    def parse!
      send("parse_as_#{@format}")
      @rows
    end

    def file=(value)
      fail StandardError, 'Invalid pricelist file' if !value || !File.file?(value)
      @file       = value.respond_to?(:path) ? value : File.new(value)
      self.format = File.extname(@file).delete('.') unless @format
    end

    def format=(value)
      fail StandardError, 'Invalid pricelist file format' unless self.class.supported_format?(value)
      @format = value
    end

    private

    def parse_as_xml
      xml       = File.read(@file, encoding: @encoding)
      doc       = Nokogiri::HTML(xml.force_encoding('UTF-8'))
      doc.search(@start).each do |product|
        row = {}
        @columns.each_pair do |k, v|
          val = product.search(v).first
          val = val.to_i if (k == 'articul') && (val.kind_of?(Float))
          row[k] = val.try(:text).to_s.strip.encode('utf-8')
        end
        @rows << row
      end
    end

    def parse_as_strict_xml
      xml       = File.read(@file, encoding: @encoding)
      doc       = Nokogiri::XML(xml.force_encoding('UTF-8'), nil, @encoding)
      doc.search(@start).each do |product|
        row = {}
        @columns.each_pair do |k, v|
          val = product.search(v).first
          val = val.to_i if (k == 'articul') && (val.kind_of?(Float))
          row[k] = val.try(:text).to_s.strip.encode('utf-8')
        end
        @rows << row
      end
    end

    def parse_as_xls
      spreadsheet = Roo::Spreadsheet.open(@file)

      # Doesn't work for Optovik
      # case @encoding
      # when 'UTF-8'
      #   spreadsheet.workbook.encoding = Encoding::UTF_8
      # when 'Windows-1251'
      #   spreadsheet.workbook.encoding = Encoding::CP1251
      # end

      @start.to_i.upto(spreadsheet.last_row) do |row_num|
        row = {}
        @columns.each do |k, v|
          val = spreadsheet.cell(row_num, v.to_i)
          val = val.to_i if (k == 'articul') && (val.kind_of?(Float))
          row[k] = val.to_s.strip.encode('utf-8')
        end
        @rows << row
      end
    end

    def parse_as_xlsx
      if Conf['b.use_go_xlsx'] == 't'
        `go run lib/go_xlsx.go #{@file.path}`
        result_file_path = "#{@file.path}.go_result"
        result_file = File.read(result_file_path)
        json = JSON.parse result_file
        rows = json[(@start.to_i - 1)..-1]
      else
        wb = Dullard::Workbook.new(@file)
        rows = wb.sheets.first.rows.to_a[(@start.to_i - 1)..-1]
      end

      rows.each do |row|
        t = {}
        @columns.each do |k, v|
          val = row[v.to_i - 1]
          val = val.to_i if (k == 'articul') && (val.kind_of?(Float))
          t[k] = val.to_s.strip.encode('utf-8')
        end
        @rows << t
      end
    ensure
      File.unlink(result_file_path) if result_file_path && File.file?(result_file_path)
    end

    def parse_as_csv
      CSV.read(@file, "r:#{@encoding}", quote_char: "#{@csv_separator}", headers: @csv_headers).each_with_index do |csv_row, i|
        if @start - 1 <= i
          row = {}
          @columns.each do |k, v|
            val = csv_row[v.to_i - 1]
            val = val.to_i if (k == 'articul') && (val.kind_of?(Float))
            row[k] = val.to_s.strip.encode('utf-8')
          end
          @rows << row
        end
      end
    end
  end
