class Catalog::FilterValue < ActiveRecord::Base
  validates :name, :filter, presence: true
  validates :name, uniqueness: { case_sensitive: false, scope: [:catalog_filter_id] }
  belongs_to :filter, class_name: Catalog::Filter, foreign_key: :catalog_filter_id
  class << self
    def to_group
      all.group_by(&:catalog_filter_id)
    end
  end
end
