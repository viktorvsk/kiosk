class Catalog::Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  def self.table_name
    'comments'
  end
end
