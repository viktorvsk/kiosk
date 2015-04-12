class Image < ActiveRecord::Base
  belongs_to :imageable, polymorphic: true
  validates :attachment, :imageable, presence: true,  if: -> { imageable.present? }
  mount_uploader :attachment, ImageUploader
  delegate :url, to: :attachment
end
