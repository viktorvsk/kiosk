module Catalog

  class << self

    def table_name_prefix
      'catalog_'
    end

    def downcase_words(str, words_ary)
      words_ary.each do |w|
        str.gsub!(/#{w}/i, w.titleize)
      end
      str
    end

    def strip_phone(phone)
      p = phone.to_s.strip
      return if p.blank?
      p.gsub!(/[^\d]/, '')
      unless p =~ /\A38/
        p = "38#{p}"
      end
      p
    end

  end
end
