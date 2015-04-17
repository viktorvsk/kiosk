class DropCategoryFilters < ActiveRecord::Migration
  def change
    drop_table :catalog_category_filter_values
  end
end
