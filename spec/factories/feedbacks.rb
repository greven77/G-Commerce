FactoryGirl.define do
  factory :feedback do
    comment Faker::Lorem.sentences
    rating (0..5).to_a.sample
    association :product
    association :user
  end
end
