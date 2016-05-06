FactoryGirl.define do
  factory :category do
    name { Faker::Commerce.department }
    parent_id nil

    factory :category_with_products do
      transient do
        product_count 5
      end

      after(:create) do |category, evaluator|
        create_list(:product, evaluator.product_count, category: category)
      end
    end
  end
end
