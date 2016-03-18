FactoryGirl.define do
  factory :image do
    association :imageable, factory: :product
    attachment File.new(Rails.root.join('test', 'support', 'rails.png'))
  end
end
