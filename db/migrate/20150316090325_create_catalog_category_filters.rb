class CreateCatalogCategoryFilters < ActiveRecord::Migration
  def change
    create_table :catalog_category_filters do |t|
      t.belongs_to :catalog_category, null: false, index: true
      t.belongs_to :catalog_filter, null: false, index: true
      t.integer :position, default: 0, null: false

      t.timestamps null: false
    end

    add_index :catalog_category_filters, [:catalog_category_id, :catalog_filter_id],
                                          unique: true,
                                          name: :category_filters_index
  end
end
