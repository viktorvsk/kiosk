FactoryGirl.define do
  factory :category, class: 'Catalog::Category' do
    name { FFaker::Product.product_name }
  end
end
