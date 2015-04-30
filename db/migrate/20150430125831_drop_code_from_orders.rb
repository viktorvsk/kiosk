class DropCodeFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :code
  end
end
