class CreateAliases < ActiveRecord::Migration
  def change
    create_table :aliases do |t|
      t.string :name, null: false, index: true
      t.references :aliasable, polymorphic: true, index: true, null: false

      t.timestamps null: false
    end
  end
end
