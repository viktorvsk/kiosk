FactoryGirl.define do
  factory :product, class: 'Catalog::Product' do
    name { FFaker::Product.product_name }
    category
  end
end
