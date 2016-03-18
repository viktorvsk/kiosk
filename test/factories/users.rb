FactoryGirl.define do
  factory :user do
    email { FFaker::Internet.email }
    password '11111111'
  end
end
