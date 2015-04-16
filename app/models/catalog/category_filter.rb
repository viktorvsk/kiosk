class Catalog::CategoryFilter < ActiveRecord::Base
  validates :position, :filter, presence: true
  validates :position, presence: true
  validates :category, presence: true, if: -> { category.present? }
  validates :catalog_filter_id, uniqueness: { scope: :catalog_category_id }
  belongs_to :category, class_name: Catalog::Category,
                                foreign_key: :catalog_category_id
  belongs_to :filter, class_name: Catalog::Filter,
                      foreign_key: :catalog_filter_id
  delegate :name, :values, to: :filter


end
