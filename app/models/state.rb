class State < ActiveRecord::Base
  belongs_to :stateable, polymorphic: true
end
