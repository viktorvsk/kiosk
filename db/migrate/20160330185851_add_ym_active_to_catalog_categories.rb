class AddYmActiveToCatalogCategories < ActiveRecord::Migration
  def change
    add_column :catalog_categories, :ym_active, :bool, default: false
    add_index :catalog_categories, :ym_active
  end
end
