FactoryGirl.define do
  factory :category_filter, class: 'Catalog::CategoryFilter' do
    filter
    category
  end
end
