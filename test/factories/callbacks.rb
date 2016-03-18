FactoryGirl.define do
  factory :callback do
    name { FFaker::Name.name }
    phone { FFaker::PhoneNumber.short_phone_number }
    body { FFaker::Lorem.paragraph }
  end
end
