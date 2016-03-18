FactoryGirl.define do
  factory :user_product_action do
    action { FFaker::Lorem.paragraph }
    action_type { FFaker::Lorem.sentence }
    product
    user
  end
end
