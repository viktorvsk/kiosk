FactoryGirl.define do
  factory :alias do
    name { FFaker::Product.product_name }
    association :aliasable, factory: :product
  end
end
