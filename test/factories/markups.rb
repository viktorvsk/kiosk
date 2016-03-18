FactoryGirl.define do
  factory :markup do
    body { FFaker::Lorem.paragraph }
    name { FFaker::Lorem.word }
    slug { FFaker::Lorem.word.parameterize }
    active true

    trait :page do
      markup_type 'page'
    end
    trait :article do
      markup_type 'article'
    end
    trait :help do
      markup_type 'help'
    end
    trait :slide do
      markup_type 'slide'
    end
  end
end
