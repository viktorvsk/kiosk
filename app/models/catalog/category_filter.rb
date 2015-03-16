class Catalog::CategoryFilter < ActiveRecord::Base
  validates :position, :filter, :brand, presence: true
end
