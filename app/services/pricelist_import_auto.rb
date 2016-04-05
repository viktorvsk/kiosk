class PricelistImportAuto
  @queue = :common

  def self.perform
    merchants = Vendor::Merchant.auto_updateable
    merchants.each do |m|
      klass = "#{m.parser_class}Parser".classify.constantize
      klass.auto_update(m.id)
      puts "Queued #{m.name}"
    end
  end
end
