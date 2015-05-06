class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :name
      t.text :body
      t.boolean :active, default: false
      t.belongs_to :user, index: true
      t.string :commentable_type
      t.integer :commentable_id

      t.timestamps null: false
    end
    add_foreign_key :comments, :users
  end
end
