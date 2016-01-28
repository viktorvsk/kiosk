class AddIndexToUpdatedAt < ActiveRecord::Migration
  def change
    add_index :vendor_products, :updated_at
  end
end
