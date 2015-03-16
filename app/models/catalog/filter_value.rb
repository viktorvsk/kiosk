class Catalog::FilterValue < ActiveRecord::Base
  validates :name, :filter, presence: true
end
