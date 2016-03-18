FactoryGirl.define do
  factory :conf do
    var { FFaker::Lorem.word }
    value { FFaker::Lorem.sentence }
  end
end
