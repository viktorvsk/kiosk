class Vendor::Product < ActiveRecord::Base
  store_accessor :info, :uah, :usd, :eur, :rrc,
                 :in_stock_kharkov, :in_stock_kiev,
                 :model, :brand, :category,
                 :warranty
  validates :name, :articul, :vendor_merchant_id, :price, :in_stock, :is_rrc, presence: true

  class << self
    def to_csv
      all.map(&:to_csv).join("\n");
    end
  end

  def to_partial_path
    "admin/#{super}"
  end

  def to_csv
    [
      articul,
      name,
      price,
      in_stock,
      vendor_merchant_id,
      catalog_product_id,
      -> { Time.now }.call,
      -> { Time.now }.call,
      info.to_json,
      is_rrc
    ]
  end
end
