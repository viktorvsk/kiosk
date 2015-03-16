class CreateCatalogCategories < ActiveRecord::Migration
  def change
    create_table :catalog_categories do |t|
      t.string :name, default: '', null: false, index: true
      t.string :slug, default: '', null: false, index: true

      t.timestamps null: false
    end

  end
end
