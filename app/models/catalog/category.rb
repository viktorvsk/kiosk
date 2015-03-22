class Catalog::Category < ActiveRecord::Base
  store_accessor :info, :tax, :tax_max, :tax_threshold
  validates :name, presence: true
  has_many :products, class_name: Catalog::Product
end
