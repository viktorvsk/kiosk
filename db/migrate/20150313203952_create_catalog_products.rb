class CreateCatalogProducts < ActiveRecord::Migration
  def change
    create_table :catalog_products do |t|
      t.string :name, default: '', null: false
      t.timestamps null: false
    end
    add_index(:catalog_products, :name)
  end
end
