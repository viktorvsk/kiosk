class CreateCatalogProductProperties < ActiveRecord::Migration
  def change
    create_table :catalog_product_properties do |t|
      t.string :name, default: '', null: false
      t.belongs_to :catalog_product, null: false, index: true
      t.belongs_to :catalog_property, null: false, index: true
      t.timestamps null: false
    end

    add_index :catalog_product_properties, [:catalog_product_id, :catalog_property_id],
                                           unique: true,
                                           name: :product_properties_index
  end
end
