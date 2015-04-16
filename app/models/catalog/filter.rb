class Catalog::Filter < ActiveRecord::Base
  validates :name, presence: true
  has_many :values, class_name: Catalog::FilterValue, foreign_key: :catalog_filter_id
  has_many :category_filters, class_name: Catalog::CategoryFilter,
                              foreign_key: :catalog_filter_id
  def value=(val)
    val.strip!
  end
end
