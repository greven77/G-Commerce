FactoryGirl.define do
  factory :payment do
    type "Mastercard"
    card_number { Faker::Number.number(16) }
    valid_until { Faker::Business.credit_card_expiry_date.strftime("%m/%y") }
    verification_code { Faker::Number.number(3) }
    customer nil
  end
end
