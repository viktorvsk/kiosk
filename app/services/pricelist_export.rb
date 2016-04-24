class PricelistExport
  @queue = :extra

  def self.perform(ids, filename, available, multiplier)
    categories = Catalog::Category.where(id: ids.split(','))
    warranty_id = Catalog::Property.warranty.try(:id)
    output_path = Rails.public_path.join(filename)
    pricelist = ActionController::Base.new.render_to_string('catalog/price', locals: {
                                                                                categories: categories,
                                                                                warranty_id: warranty_id,
                                                                                offer_available: available,
                                                                                price_multiplier: multiplier
                                                                              })
    File.open(output_path, 'w') { |f| f.puts pricelist }
  end



  def initialize(marketplace_name)
    case marketplace_name
    when 'ym'
      @ids = Catalog::Category.pricelist_association.yandex_market.pluck(:id).join(',')
      @filename = 'price_yandex.xml'
      @offer_available = 'false'
      @multiplier = 1.00
    when 'pn'
      @ids = Catalog::Category.pricelist_association.pluck(:id).join(',')
      @filename = 'price_full.xml'
      @offer_available = 'true'
      @multiplier = 1.00
    end
  end

  def async_generate!
    Resque.enqueue(self.class, @ids, @filename, @offer_available, @multiplier)
  end

  def generate!
    self.class.perform(@ids, @filename, @offer_available, @multiplier)
  end
end
