class Catalog::CategoryProperty < ActiveRecord::Base
  validates :position, :property, :brand, presence: true
end
