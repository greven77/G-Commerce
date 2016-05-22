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

  context "search" do
    before do
      orders = FactoryGirl.create_list(:order, 10)
      @order = orders.sample
      Order.reindex
      Order.searchkick_index.refresh
    end

    it "by customer name" do
      search_term = @order.customer.name[0..2]
      expect(Order.search(search_term)).not_to be_empty
    end

    it "by order status" do
      search_term = @order.order_status.description
      result = Order.search(search_term)
      expect(result.first.order_status.description).to eq(@order.order_status.description)
    end
  end
end
