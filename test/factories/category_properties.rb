FactoryGirl.define do
  factory :category_property, class: 'Catalog::CategoryProperty' do
    category
    property
  end
end
