FactoryGirl.define do
  factory :product_filter_value, class: 'Catalog::ProductFilterValue' do
    product
    filter
    filter_value
  end
end
