module ActivePricelist
  class Reader
    SUPPORTED_FORMATS = %w(xml xls xlsx csv).freeze
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
      fail FileError, 'Invalid pricelist file' if !value || !File.file?(value)
      @file       = value.respond_to?(:path) ? value : File.new(value)
      self.format = File.extname(@file).delete('.') unless @format
    end

    def format=(value)
      fail FileError, 'Invalid pricelist file format' unless self.class.supported_format?(value)
      @format = value
    end

    private

    def parse_as_xml
      xml       = File.read(@file, encoding: @encoding)
      doc       = Nokogiri::HTML(xml.force_encoding('UTF-8'))
      doc.search(@start).each do |product|
        row = {}
        @columns.each_pair do |k, v|
          row[k] = product.search(v).first.try(:to_s)
        end
        @rows << row
      end
    end

    def parse_as_xls
      spreadsheet = Roo::Spreadsheet.open(@file)
      @start.to_i.upto(spreadsheet.last_row) do |row_num|
        row = {}
        @columns.each { |k, v| row[k] = spreadsheet.cell(row_num, v.to_i).to_s }
        @rows << row
      end
    end

    def parse_as_xlsx
      wb    = Dullard::Workbook.new(@file)
      rows  = wb.sheets.first.rows.to_a
      @start.to_i.upto(rows.count) do |row_num|
        obj = {}
        @columns.each { |k, v| obj[k] = rows[row_num - 1][v.to_i - 1].to_s }
        @rows << obj
      end
    end

    def parse_as_csv
      CSV.read(@file, "r:#{@encoding}", quote_char: "#{@csv_separator}", headers: @csv_headers).each_with_index do |csv_row, i|
        if @start - 1 <= i
          row = {}
          @columns.each { |k, v| row[k] = csv_row[v.to_i - 1].to_s }
          @rows << row
        end
      end
    end
  end
end
