class FixCallbacksActiveDefaults < ActiveRecord::Migration
  def change
    change_column_default :callbacks, :active, false
  end
end
