FactoryGirl.define do
  factory :product do
    name "MyString"
    product_code "MyString"
    description "MyString"
    price "9.99"

    trait :nameless do
      name nil
      to_create { |instance| instance.save(validate: false) }
    end

    trait :priceless do
      price nil
      to_create { |instance| instance.save(validate: false) }
    end
  end
end
