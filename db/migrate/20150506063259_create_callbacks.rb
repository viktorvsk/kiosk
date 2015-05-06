class CreateCallbacks < ActiveRecord::Migration
  def change
    create_table :callbacks do |t|
      t.string :name
      t.string :phone
      t.text :body
      t.belongs_to :user
      t.boolean :active, default: true
      t.timestamps null: false
    end
    add_index :callbacks, :user_id
  end
end
