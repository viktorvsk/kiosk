class AddTrashedAndCurrentPriceToVendorProducts < ActiveRecord::Migration
  def change
    add_column :vendor_products, :trashed, :bool, default: false
    add_column :vendor_products, :current_price, :bool, default: true
    add_index :vendor_products, :current_price
  end
end
