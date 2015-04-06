class Catalog::CategoryProperty < ActiveRecord::Base
  before_create :set_position
  validates :position, presence: true
  validates :category, presence: true, if: -> { category.present? }
  validates :catalog_property_id, uniqueness: { scope: :catalog_category_id }
  belongs_to :property, class_name: Catalog::Property, foreign_key: :catalog_property_id
  belongs_to :category, class_name: Catalog::Category, foreign_key: :catalog_category_id
  delegate :name, to: :property, allow_nil: true

  private

  def set_position
    max_position = if category
      category.category_properties.max_by(&:position).try(:position).to_i
    else
      100
    end
    position = max_position + 1
  end
end
