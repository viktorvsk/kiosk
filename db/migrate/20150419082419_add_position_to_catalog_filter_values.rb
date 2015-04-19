class AddPositionToCatalogFilterValues < ActiveRecord::Migration
  def change
    add_column :catalog_filter_values, :position, :integer
  end
end
