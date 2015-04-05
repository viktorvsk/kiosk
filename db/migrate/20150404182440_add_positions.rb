class AddPositions < ActiveRecord::Migration
  def change
    add_column :catalog_product_properties, :position, :integer, default: 0
  end
end
