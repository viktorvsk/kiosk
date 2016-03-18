FactoryGirl.define do
  factory :product_property, class: 'Catalog::ProductProperty' do
    property
    product
  end
end
