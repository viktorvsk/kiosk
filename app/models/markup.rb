class Markup < ActiveRecord::Base
  include Slugable
  TYPES = %w(page article help callback slide)
  TYPES.each do |t|
    scope t.pluralize.to_sym, -> { where(markup_type: t) }
  end
  scope :active, -> { where(active: true) }
end
