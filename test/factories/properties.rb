FactoryGirl.define do
  factory :property, class: 'Catalog::Property' do
    name { FFaker::Product.product_name }
  end
end
