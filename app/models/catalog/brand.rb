class Catalog::Brand < ActiveRecord::Base
  store_accessor :info, :description
  validates :name, :slug, :description, presence: true
end
