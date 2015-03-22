class Vendor::Product < ActiveRecord::Base
  store_accessor :info, :uah, :usd, :eur, :rrc,
                 :in_stock_kharkov, :in_stock_kiev,
                 :model, :brand, :category,
                 :warranty
  validates :name, :articul, :merchant, :price, :in_stock, :is_rrc, presence: true
  belongs_to :product, class_name: Catalog::Product, foreign_key: :catalog_product_id
  belongs_to :merchant, class_name: Vendor::Merchant, foreign_key: :vendor_merchant_id

  class << self
    def to_csv
      all.map(&:to_csv).join("\n");
    end

    def unbind
       all.update_all( product: nil )
    end

    def bind_to( catalog_product )
      all.update_all( product: catalog_product )
    end
  end

  def bind_to( catalog_product )
    update( product: catalog_product )
  end

  def unbind
    update( product: nil )
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
