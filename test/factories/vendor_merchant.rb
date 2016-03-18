FactoryGirl.define do
  factory :vendor_merchant, class: 'Vendor::Merchant' do
    name { FFaker::Company.name }
  end
end
