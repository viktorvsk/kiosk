class Catalog::Brand < ActiveRecord::Base

  store_accessor :info, :description, :slug
  validates :name, :slug, :description, presence: true
  has_one :seo, as: :seoable, dependent: :destroy
  has_one :image, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :seo
  accepts_nested_attributes_for :image
end
