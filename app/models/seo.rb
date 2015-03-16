class Seo < ActiveRecord::Base
  belongs_to :seoable, polymorphic: true
end
