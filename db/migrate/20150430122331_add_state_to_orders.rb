class AddStateToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :state, :string, default: 'in_cart'
  end
end
