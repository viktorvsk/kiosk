class Markup < ActiveRecord::Base
  include Slugable
  TYPES = %w(page article help slide)
  TYPES.each do |t|
    scope t.pluralize.to_sym, -> { where(markup_type: t) }
  end
  scope :pages_and_articles, -> { where("markup_type IN ('page','article')") }
  scope :active, -> { where(active: true) }
end
