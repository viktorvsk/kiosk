class Catalog::Product < ActiveRecord::Base
  store_accessor :info, :video, :description, :accessories
  validates :name, :slug, :model, :category, :brand, :fixed_price, :price, presence: true
  belongs_to :category, class_name: Catalog::Category
  belongs_to :brand, class_name: Catalog::Brand
end
