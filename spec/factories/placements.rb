FactoryGirl.define do
  factory :placement do
    order nil
    quantity { (1..5).to_a.sample }
    association :product
  end
end
