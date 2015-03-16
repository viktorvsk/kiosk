class Catalog::Property < ActiveRecord::Base
  validates :name, presence: true
end
