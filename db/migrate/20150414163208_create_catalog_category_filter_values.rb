class CreateCatalogCategoryFilterValues < ActiveRecord::Migration
  def change
    create_table :catalog_category_filter_values do |t|
      t.belongs_to :catalog_category, null: false, index: true
      t.belongs_to :catalog_filter_value, null: false, index: true
      t.timestamps null: false
    end

  end
end
