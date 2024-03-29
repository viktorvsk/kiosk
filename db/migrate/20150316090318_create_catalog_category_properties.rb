class CreateCatalogCategoryProperties < ActiveRecord::Migration
  def change
    create_table :catalog_category_properties do |t|
      t.belongs_to :catalog_category, null: false, index: true
      t.belongs_to :catalog_property, null: false, index: true
      t.integer :position, default: 0, null: false

      t.timestamps null: false
    end

    add_index :catalog_category_properties, [:catalog_category_id, :catalog_property_id],
                                            unique: true,
                                            name: :category_properties_index
  end
end
