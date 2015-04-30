class ChangeUserConstraintsToOrders < ActiveRecord::Migration
  def change
    change_column_null :orders, :user_id, true
  end
end
