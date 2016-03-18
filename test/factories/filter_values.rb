FactoryGirl.define do
  factory :filter_value, class: 'Catalog::FilterValue' do
    name { FFaker::Product.product_name }
    association :filter, factory: :filter
  end
end
