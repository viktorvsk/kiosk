class CreateAliasesAgain < ActiveRecord::Migration
  def change
    create_table :aliases do |t|
      t.string :name, null: false, index: true
      t.references :aliasable, polymorphic: true, null: false, index: true

      t.timestamps null: false
    end

    add_index :aliases, [:name, :aliasable_type, :aliasable_id], unique: true
  end
end
