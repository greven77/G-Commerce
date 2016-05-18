FactoryGirl.define do
  factory :order do
    total 1.5
    association :customer
    association :order_status
  end
end
