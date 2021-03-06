FactoryGirl.define do
  factory :product do
    name { Faker::Commerce.product_name }
    product_code { Faker::Code.ean }
    description "MyString"
    price { Faker::Commerce.price }
    association :category
    trait :with_image do
      image { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'fixtures', 'files',
                                                     'image1.jpg'))}
      after(:create) do |obj|
        obj.image_url = obj.image.url
      end
    end

    
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
