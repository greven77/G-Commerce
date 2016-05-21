# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password "password"
    password_confirmation "password"
    association :role, :name => "customer"

    trait :customer do
      email {Faker::Internet.email}
      association :role, :name => "customer"
    end

    trait :admin do
      email {Faker::Internet.email}
      association :role, :name => "admin"
    end

    trait :tokenless do
      email {Faker::Internet.email}
      after(:create) { |instance| instance.clear_authentication_token }
    end
  end
end
