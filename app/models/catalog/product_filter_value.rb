class Catalog::ProductFilterValue < ActiveRecord::Base
  validates :product, :filter, presence: true
end
