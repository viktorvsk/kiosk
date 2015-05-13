class RemoveUniquePhoneIndex < ActiveRecord::Migration
  def change
    remove_index :users, name: 'index_users_on_phone', column: :phone
  end
end
