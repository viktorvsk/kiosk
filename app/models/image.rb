class Image < ActiveRecord::Base
  belongs_to :imageable, polymorphic: true
  validates :attachment, :imageable, presence: true
  mount_uploader :attachment, ImageUploader
  delegate :url, to: :attachment
end
