FactoryGirl.define do
  factory :product do
    name "MyString"
    product_code "MyString"
    description "MyString"
    price "9.99"

    factory :product_with_feedback do
      transient do
        feedback_count 5
      end

      after(:create) do |product, evaluator|
        create_list(:feedback, evaluator.feedback_count, product: product)
      end
    end

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
