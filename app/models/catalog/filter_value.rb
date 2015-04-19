class Catalog::FilterValue < ActiveRecord::Base
  before_create :set_position
  validates :name, :filter, presence: true
  validates :name, uniqueness: { case_sensitive: false, scope: [:catalog_filter_id] }
  belongs_to :filter, class_name: Catalog::Filter, foreign_key: :catalog_filter_id
  class << self
    def to_group
      all.group_by(&:catalog_filter_id)
    end
  end

  private

  def set_position
    max_position = if filter
      filter.values.max_by(&:position).try(:position).to_i
    else
      100
    end
    self.position = max_position + 1
  end

end
