class CreateCatalogFilterValues < ActiveRecord::Migration
  def change
    create_table :catalog_filter_values do |t|
      t.string :name, null: false
      t.belongs_to :catalog_filter, null: false, index: true
      t.timestamps null: false
    end

    add_index :catalog_filter_values, [:name, :catalog_filter_id], unique: true
  end
end
