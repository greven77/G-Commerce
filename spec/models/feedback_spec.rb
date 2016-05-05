require 'rails_helper'

RSpec.describe Feedback, type: :model do
  let!(:feedback) { FactoryGirl.create(:feedback)}
  it { should belong_to :product }
  it { should belong_to :user }
  it { should validate_presence_of :comment }
  it { should validate_presence_of :rating }
  it { should validate_presence_of :user_id }
  it { should validate_presence_of :product_id }

  describe "Rating range validation" do
    it "should have positive rating" do
      feedback.rating = -1
      feedback.save
      expect(feedback.errors[:rating].size).to eq(1)
    end

    it "should have 5 as max rating" do
      feedback.rating = 6
      feedback.save
      expect(feedback.errors[:rating].size).to eq(1)
    end

    it "should accept a value between 0 and 5 as rating" do
      feedback.rating = (0..5).to_a.sample
      feedback.save
      expect(feedback.errors[:rating].size).to eq(0)
    end
  end
end
