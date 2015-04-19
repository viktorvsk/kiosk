class AddCatalogTaxonIdToCatalogCategories < ActiveRecord::Migration
  def change
    add_column :catalog_categories, :catalog_taxon_id, :integer
    add_index :catalog_categories, :catalog_taxon_id
  end
end
