class CreateCatalogFilters < ActiveRecord::Migration
  def change
    create_table :catalog_filters do |t|
      t.string :name, default: '', null: false

      t.timestamps null: false
    end
  end
end
