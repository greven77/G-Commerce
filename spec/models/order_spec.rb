require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:order) { FactoryGirl.build :order }
  subject { order }

  it { should respond_to(:total) }
  it { should respond_to(:customer_id) }
  it { should respond_to(:order_status_id) }

  it { should validate_presence_of :customer_id }

  it { should belong_to :customer }
  it { should belong_to :order_status }

  it "should assign a default state" do
    expect(order).to receive(:assign_default_status)
    order.save
  end

  it { should have_many(:placements) }
  it { should have_many(:products).through(:placements) }
end