class Catalog::CategoryBrand < ActiveRecord::Base

  validates :position, :category, :brand, presence: true
end
