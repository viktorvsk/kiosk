class Catalog::CategoryFilter < ActiveRecord::Base
  before_create :set_position
  validates :position, :filter, presence: true
  validates :position, presence: true
  validates :category, presence: true, if: -> { category.present? }
  validates :catalog_filter_id, uniqueness: { scope: :catalog_category_id }
  belongs_to :category, class_name: Catalog::Category,
                                foreign_key: :catalog_category_id
  belongs_to :filter, class_name: Catalog::Filter,
                      foreign_key: :catalog_filter_id
  delegate :name, :values, :display_name, to: :filter

  private

  def set_position
    max_position = category.category_filters.max_by(&:position).try(:position).to_i
    self.position = max_position + 1
  end

end
