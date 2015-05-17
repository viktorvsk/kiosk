class AddInfoToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :info, :json
  end
end
