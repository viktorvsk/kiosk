class ModifyFilters < ActiveRecord::Migration
  def change
    begin
      Catalog::CategoryFilterValue
      drop_table :catalog_category_filter_values
    rescue NameError
    end
    change_column_null :catalog_product_filter_values, :catalog_filter_value_id, true, ''
    add_column :catalog_filters, :display_name, :string
    add_column :catalog_filter_values, :display_name, :string
    add_column :catalog_product_filter_values, :catalog_filter_id, :integer, null: false, default: ''
    add_index :catalog_product_filter_values, :catalog_filter_id
  end
end
