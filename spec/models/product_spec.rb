require 'rails_helper'

RSpec.describe Product, type: :model do
  let!(:customer) { FactoryGirl.create(:customer) }
  let!(:product) { FactoryGirl.create(:product) }
  before do
    product.feedbacks.create(rating: 0, customer: customer, comment: Faker::Lorem.sentence(3))
    product.feedbacks.create(rating: 1, customer: customer, comment: Faker::Lorem.sentence(3))
    product.feedbacks.create(rating: 4, customer: customer, comment: Faker::Lorem.sentence(3))
    product.feedbacks.create(rating: 5, customer: customer, comment: Faker::Lorem.sentence(3))
  end

  it 'should calculate the average rate correctly' do
    expect(product.rating).to eq(2.5)
  end

  it { should have_many(:placements) }
  it { should have_many(:orders).through(:placements) }
end
