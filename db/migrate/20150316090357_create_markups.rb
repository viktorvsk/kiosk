class CreateMarkups < ActiveRecord::Migration
  def change
    create_table :markups do |t|
      t.string :name, default: '', null: false
      t.text :body, null: false
      t.hstore :info
      t.references :markupable, polymorphic: true, index: true, null: false

      t.timestamps null: false
    end

    add_index :markups, :name, unique: true
  end
end
