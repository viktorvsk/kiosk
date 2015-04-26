class Catalog::FilterValue < ActiveRecord::Base
  before_create :set_position
  validates :name, :filter, presence: true
  validates :name, uniqueness: { case_sensitive: false, scope: [:catalog_filter_id] }
  belongs_to :filter, class_name: Catalog::Filter, foreign_key: :catalog_filter_id
  class << self
    def to_group
      all.group_by(&:catalog_filter_id)
    end

    def count_w(id, params, products)
      s = ''
      init_count = products.count
      p = Marshal.load(Marshal.dump(params))
      filtered = p[:f].to_s.split(',').map(&:strip)
      checked_state = filtered.include?(id)
      action = checked_state ? :delete : :push
      p[:f] = p[:f].to_s.split(',').map(&:strip).send(action, id).join(',')
      count = products.unscoped.by_category_params(p).count
      return [checked_state, count]
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
