class AddActiveToCatalogCategories < ActiveRecord::Migration
  def change
    add_column :catalog_categories, :active, :boolean, null: false, default: true
    add_index :catalog_categories, :active
  end
end
