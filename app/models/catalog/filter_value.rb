class Catalog::FilterValue < ActiveRecord::Base
  validates :name, :filter, presence: true
  belongs_to :filter, class_name: Catalog::Filter, foreign_key: :catalog_filter_id
end
