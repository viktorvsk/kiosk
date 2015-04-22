class Catalog::Taxon < ActiveRecord::Base
  before_create :set_position
  has_many :categories, class_name: Catalog::Category, foreign_key: :catalog_taxon_id
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  has_ancestry

  private

  def set_position
    self.position = siblings.count + 1
  end
end
