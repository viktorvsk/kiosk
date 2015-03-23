class Catalog::Category < ActiveRecord::Base
  store_accessor :info, :tax, :tax_max, :tax_threshold
  validates :name, presence: true
  has_many :products, class_name: Catalog::Product, dependent: :nullify, foreign_key: :catalog_category_id
  has_many :vendor_products, through: :products, class_name: ::Vendor::Product

end
