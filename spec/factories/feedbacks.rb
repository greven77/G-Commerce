FactoryGirl.define do
  factory :feedback do
    comment Faker::Lorem.sentences
    rating (0..5).to_a.sample
    association :product
    association :user

    trait :commentless do
      comment nil
    end

    trait :ratingless do
      rating nil
    end
  end
end
