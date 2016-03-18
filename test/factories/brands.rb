FactoryGirl.define do
  factory :brand, class: 'Catalog::Brand' do
    name { FFaker::Product.brand }
    slug { FFaker::Product.brand }
    description { FFaker::Lorem.paragraph }
  end
end
