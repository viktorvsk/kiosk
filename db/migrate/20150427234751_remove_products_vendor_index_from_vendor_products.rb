class RemoveProductsVendorIndexFromVendorProducts < ActiveRecord::Migration
  def change
    remove_index :vendor_products, name: :products_vendor_index, column: [:name, :vendor_merchant_id]
    remove_index :vendor_products, name: :index_vendor_products_on_name, column: :name
  end
end
