class CreateUserProductActions < ActiveRecord::Migration
  def change
    create_table :user_product_actions do |t|
      t.integer :product_id
      t.string :action_type
      t.integer :user_id
      t.text :action

      t.timestamps null: false
    end
    add_index :user_product_actions, :product_id
    add_index :user_product_actions, :action_type
    add_index :user_product_actions, :user_id
  end
end
