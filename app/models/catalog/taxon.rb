class Catalog::Taxon < ActiveRecord::Base
  include Slugable
  before_create :set_position
  # after_update :rerender_menu
  has_one :category, class_name: Catalog::Category, foreign_key: :catalog_taxon_id
  has_one :image, as: :imageable, dependent: :destroy
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  accepts_nested_attributes_for :image

  has_ancestry

  def self.expire_menu_cache_fragment
    ActionController::Base.new.expire_fragment 'catalog_menu'
  end

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

  def rerender_menu
    self.class.expire_menu_cache_fragment
  end

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
