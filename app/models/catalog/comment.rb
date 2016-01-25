class Catalog::Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  scope :olds, -> { where(active: true) }
  scope :news, -> { where(active: false) }
  scope :with_product, -> { where(commentable_type: 'Catalog::Product').includes(:commentable) }

  def self.table_name
    'comments'
  end
end
