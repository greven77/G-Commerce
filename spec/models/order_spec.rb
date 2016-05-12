require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:order) { FactoryGirl.build :order }
  subject { order }

  it { should respond_to(:total) }
  it { should respond_to(:user_id) }
  it { should respond_to(:order_status_id) }

  it { should validate_presence_of :user_id }
  it { should validate_presence_of :total }
  it { should validate_numericality_of(:total).is_greater_than_or_equal_to(0) }

  it { should belong_to :user }
  it { should belong_to :order_status }


  it "should assign a default state" do
    expect(order).to receive(:assign_default_status)
    order.save
  end
end
