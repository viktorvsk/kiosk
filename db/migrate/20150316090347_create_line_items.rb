class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.integer :quantity, default: 1, null: false
      t.integer :price, default: 0, null: false
      t.integer :vendor_price, index: true, null: false, default: 0
      t.belongs_to :catalog_product, index: true, null: false
      t.belongs_to :order, index: true, null: false

      t.timestamps null: false
    end

    add_index :line_items, [:catalog_product_id, :order_id], unique: true, name: :line_items_order_product_index
  end
end
