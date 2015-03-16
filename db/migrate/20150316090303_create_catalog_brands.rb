class CreateCatalogBrands < ActiveRecord::Migration
  def change
    create_table :catalog_brands do |t|
      t.string :name, null: false, default: ''
      t.hstore :info

      t.timestamps null: false
    end

    add_index :catalog_brands, :name, unique: true
  end
end
