class Catalog::ProductProperty < ActiveRecord::Base
  validates :name, :product, :property, presence: true
end
