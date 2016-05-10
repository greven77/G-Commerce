FactoryGirl.define do
  factory :category do
    name { Faker::Commerce.department }
    parent nil

    trait :fixed_id do
      id 1
    end

    factory :category_with_products do
      transient do
        product_count 150
      end

      after(:create) do |category, evaluator|
        create_list(:product, evaluator.product_count, category: category)
        category.add_subcategories [{"name" => "name1"}, {"name" => "name2"}]
      end
    end
  end
end
