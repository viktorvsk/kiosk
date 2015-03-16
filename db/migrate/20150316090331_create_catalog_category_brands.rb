class CreateCatalogCategoryBrands < ActiveRecord::Migration
  def change
    create_table :catalog_category_brands do |t|
      t.belongs_to :catalog_category, null: false, index: true
      t.belongs_to :catalog_brand, null: false, index: true
      t.integer :position, default: 0, null: false

      t.timestamps null: false
    end

    add_index :catalog_category_brands, [:catalog_category_id, :catalog_brand_id],
                                        unique: true,
                                        name: :category_brands_index
  end
end
