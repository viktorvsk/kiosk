module ActivePricelist
  class Decoder
    attr_accessor :file

    def initialize(file)
      @file = file
    end

    def xls
      return file unless file.workbook.encoding.equal? Encoding::CP1252
      file.tap { |f| f.workbook.encoding = Encoding::CP1251 }
    end
  end
end
