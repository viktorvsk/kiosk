class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.string :name, index: true, null: false, default: ''
      t.references :stateable, polymorphic: true, index: true, null: false

      t.timestamps null: false
    end

    # Can`t do this way. Should be handled on application level
    # Some models must have multiple states
    # add_index :states, [:stateable_type, :stateable_id], unique: true
  end
end
