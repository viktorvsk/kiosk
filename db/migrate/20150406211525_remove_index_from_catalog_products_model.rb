class RemoveIndexFromCatalogProductsModel < ActiveRecord::Migration
  def change
    remove_index :catalog_products, :model
  end
end
