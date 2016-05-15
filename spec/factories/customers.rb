FactoryGirl.define do
  factory :customer do
    association :user, :factory => [:user, :customer]
    name { Faker::Name.name }
    phone { Faker::PhoneNumber.phone_number }
    association :billing_address, factory: :address
    association :shipping_address, factory: :address
  end
end
