class UserProductAction < ActiveRecord::Base
  belongs_to :user
  belongs_to :product, class_name: Catalog::Product, foreign_key: :product_id
  validates :user, :product, :action, :action_type, presence: true
end
