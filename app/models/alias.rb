class Alias < ActiveRecord::Base
  belongs_to :aliasable, polymorphic: true
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :aliasable, presence: true
end
