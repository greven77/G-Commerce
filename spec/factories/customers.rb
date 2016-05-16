FactoryGirl.define do
  factory :customer do
    association :user, :factory => [:user, :customer]
    name { Faker::Name.name }
    phone { Faker::PhoneNumber.phone_number }
    association :billing_address, factory: :address
    association :shipping_address, factory: :address
    association :payment_method, factory: :payment

    factory :customer_with_feedback do
      transient do
        feedback_count 5
      end

      after(:create) do |customer, evaluator|
        create_list(:feedback, evaluator.feedback_count, customer: customer)
      end
    end
  end
end
