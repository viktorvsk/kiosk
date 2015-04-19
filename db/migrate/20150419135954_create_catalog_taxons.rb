class CreateCatalogTaxons < ActiveRecord::Migration
  def change
    create_table :catalog_taxons do |t|
      t.string :name
      t.string :slug
      t.integer :position
      t.string :ancestry
      t.timestamps null: false
    end

    add_index :catalog_taxons, :ancestry
  end
end
