class CreateVendorMerchants < ActiveRecord::Migration
  def change
    create_table :vendor_merchants do |t|
      t.string :name, null: false
      t.json :settings
      t.hstore :info

      t.timestamps null: false
    end

    add_index :vendor_merchants, :name, unique: true
  end
end
