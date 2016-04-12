class Markup < ActiveRecord::Base
  include Slugable
  has_one :seo, as: :seoable, dependent: :destroy
  validates :markup_type, presence: true
  TYPES = %w(page article help slide)
  TYPES.each do |t|
    scope t.pluralize.to_sym, -> { where(markup_type: t) }
  end
  scope :pages_and_articles, -> { where("markup_type IN ('page','article')") }
  scope :active, -> { where(active: true) }
  accepts_nested_attributes_for :seo
end
