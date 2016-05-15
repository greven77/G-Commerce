FactoryGirl.define do
  factory :address do
    street { Faker::Address.street_address }
    post_code { Faker::Address.postcode }
    city { Faker::Address.city }
    association :country
   # association :customer
  end
end
