FactoryGirl.define do
  factory :taxon, class: 'Catalog::Taxon' do
    name { FFaker::Product.product_name }
  end
end
