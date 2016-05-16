FactoryGirl.define do
  factory :order do
    total 1.5
    association :customer
  end
end
