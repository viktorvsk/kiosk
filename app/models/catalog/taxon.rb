class Catalog::Taxon < ActiveRecord::Base
  before_create :set_position
  has_one :category, class_name: Catalog::Category, foreign_key: :catalog_taxon_id
  has_one :image, as: :imageable, dependent: :destroy
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  accepts_nested_attributes_for :image

  has_ancestry

  private

  def set_position
    self.position = siblings.count + 1
  end
end
