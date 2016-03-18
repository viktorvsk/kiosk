FactoryGirl.define do
  factory :vendor_product, class: 'Vendor::Product' do
    name { FFaker::Product.product_name }
    articul { FFaker::Guid.guid }
    association :merchant, factory: :vendor_merchant
  end
end
