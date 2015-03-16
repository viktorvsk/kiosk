class Catalog::Filter < ActiveRecord::Base
  validates :name, presence: true
end
