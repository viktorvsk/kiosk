class CreateCatalogProducts < ActiveRecord::Migration
  def change
    create_table :catalog_products do |t|
      t.string :name, default: '', null: false, index: true
      t.string :slug, default: '', null: false
      t.string :model, default: '', null: false
      t.belongs_to :catalog_category, index: true, default: '', null: false
      t.belongs_to :catalog_brand, index: true, default: '', null: false
      t.boolean :fixed_price, default: false, null: false, index: true
      t.integer :price, index: true, default: 0, null: false
      t.hstore :info

      t.timestamps null: false
    end

    add_index :catalog_products, :slug, unique: true
    add_index :catalog_products, :model, unique: true
  end
end
