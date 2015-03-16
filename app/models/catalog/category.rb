class Catalog::Category < ActiveRecord::Base
  store_accessor :info, :tax, :tax_max, :tax_threshold
  validates :name, :slut, :position, :tax, :tax_max, :tax_threshold, presence: true
end
