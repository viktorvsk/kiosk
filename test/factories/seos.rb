FactoryGirl.define do
  factory :seo do
    association :seoable, factory: :product
  end
end
