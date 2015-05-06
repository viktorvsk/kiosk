class DropAliases < ActiveRecord::Migration
  def change
    drop_table :aliases do |t|
      t.string :name, null: false, index: true
      t.references :aliasable, polymorphic: true, index: true, null: false

      t.timestamps null: false
    end
  end
end
