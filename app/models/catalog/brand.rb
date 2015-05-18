class Catalog::Brand < ActiveRecord::Base

  store_accessor :info, :description, :slug
  validates :name, :slug, :description, presence: true
  validates :name, uniqueness: { case_insensitive: true }
  has_one :seo, as: :seoable, dependent: :destroy
  has_one :image, as: :imageable, dependent: :destroy
  has_many :products, class_name: Catalog::Product, foreign_key: :catalog_brand_id
  accepts_nested_attributes_for :seo
  accepts_nested_attributes_for :image
end
