FactoryGirl.define do
  factory :filter, class: 'Catalog::Filter' do
    name { FFaker::Product.product_name }
  end
end
