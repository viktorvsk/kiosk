class Catalog::Taxon < ActiveRecord::Base
  include Slugable
  before_create :set_position
  has_one :category, class_name: Catalog::Category, foreign_key: :catalog_taxon_id
  has_one :image, as: :imageable, dependent: :destroy
  has_one :seo, as: :seoable, dependent: :destroy
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  accepts_nested_attributes_for :image, allow_destroy: false
  accepts_nested_attributes_for :seo, allow_destroy: false

  has_ancestry

  def children_image_path
    image || super_category_random_image
  rescue
    'product_missing.png'
  end

  def category_image_path
    image || category_random_image
  rescue
    'product_missing/png'
  end

  private

  def set_position
    self.position = siblings.count + 1
  end

  def super_category_random_image
    taxon_id = children.sample.id
    random_image_for_taxon(taxon_id)
  end

  def category_random_image
    random_image_for_taxon(id)
  end

  def random_image_for_taxon(taxon_id)
    Catalog::Product.joins(category: :taxon).where(catalog_taxons: { id: taxon_id }).order("RANDOM()").joins(:images).first.images.includes(:imageable).sample
  end

end
