class CreateVendorProducts < ActiveRecord::Migration
  def change
    create_table :vendor_products do |t|
      t.text :name, null: false, index: true
      t.string :articul, null: false, default: '', index: true
      t.belongs_to :vendor_merchant, index: true, null: false
      t.belongs_to :catalog_product, index: true
      t.hstore :info
      t.integer :price, null: false, default: 0, index: true
      t.boolean :in_stock, default: true, null: false, index: true
      t.boolean :is_rrc, default: false, null: false, index: true

      t.timestamps null: false
    end

    add_index :vendor_products, [:name, :vendor_merchant_id], unique: true, name: :products_vendor_index
  end
end
