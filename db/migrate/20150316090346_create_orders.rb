class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :code, default: '', null: false, limit: 10
      t.belongs_to :user, index: true, null: false
      t.hstore :info
      t.datetime :completed_at

      t.timestamps null: false
    end

    add_index :orders, :code, unique: true
  end
end
