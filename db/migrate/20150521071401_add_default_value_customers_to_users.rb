class AddDefaultValueCustomersToUsers < ActiveRecord::Migration
  def up
    change_column :users, :role, :string, :default => 'customer'
    User.where(role: [nil, 'user']).update_all(role: 'customer')
  end

  def down
    change_column :users, :role, :string, :default => nil
  end
end
