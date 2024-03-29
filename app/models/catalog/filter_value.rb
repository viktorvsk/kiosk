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
      # TODO: Optimize filters pluses
      s = ''
      init_count = products.count
      p = Marshal.load(Marshal.dump(params))
      filtered = p[:f].to_s.split(',').map(&:strip)
      siblings = Catalog::FilterValue.includes(filter: :values).find(id).filter.values.map(&:id).map(&:to_s)
      checked_state = filtered.include?(id)
      action = checked_state ? :delete : :push
      p[:f] = p[:f].to_s.split(',').map(&:strip).send(action, id).join(',')

      count = products.unscoped.with_price.by_category_params(p).count

      if (filtered & siblings).present?
        if count == init_count
          count = 0
        elsif count > init_count
          count = count - init_count
        end
        s = '+'
      end

      return "#{s}#{count}"
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
