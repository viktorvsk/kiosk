class Callback < ActiveRecord::Base
  belongs_to :user
  validates :name, :phone, :body, presence: true
  scope :news, -> { where(active: true) }
  scope :olds, -> { where(active: false) }
end
