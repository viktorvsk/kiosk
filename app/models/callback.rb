class Callback < ActiveRecord::Base
  belongs_to :user
  validates :name, :phone, :body, presence: true
end
