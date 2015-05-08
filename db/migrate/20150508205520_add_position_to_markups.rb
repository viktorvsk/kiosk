class AddPositionToMarkups < ActiveRecord::Migration
  def change
    add_column :markups, :position, :integer, default: 0
  end
end
