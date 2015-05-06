module Catalog
  def self.table_name_prefix
    'catalog_'
  end

  def self.strip_phone(phone)
    p = phone.to_s.strip
    return if p.blank?
    p.gsub!(/[^\d]/, '')
    unless p =~ /\A38/
      p = "38#{p}"
    end
    p
  end

end
