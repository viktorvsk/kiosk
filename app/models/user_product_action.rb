class UserProductAction < ActiveRecord::Base
  ACTION_TYPES = %w(Привязал Отвязал Создал Отредактировал Удалил)

  belongs_to :user
  belongs_to :product, class_name: Catalog::Product, foreign_key: :product_id
  validates :user, :product, :action, :action_type, presence: true

  scope :binded,     -> { where(action_type: 'Привязал') }
  scope :unbind,     -> { where(action_type: 'Отвязал') }
  scope :created,    -> { where(action_type: 'Создал') }
  scope :updated,    -> { where(action_type: 'Отредактировал') }
  scope :destroyed,  -> { where(action_type: 'Удалил') }

end
