require 'rails_helper'

RSpec.describe Customer, type: :model do
  let(:customer) { FactoryGirl.build :customer }
  subject { customer }

  it { should respond_to(:name) }
  it { should respond_to(:phone) }
  it { should respond_to(:billing_address) }
  it { should respond_to(:shipping_address) }
  it { should respond_to(:payment_method) }
  it { should respond_to(:user) }

  it { should belong_to(:user) }
  it { should have_one(:payment_method) }
  it { should have_one(:billing_address) }
  it { should have_one(:shipping_address) }
  it { should have_many(:orders) }
  it { should have_many(:feedbacks) }

  context "search" do
    before do
      customers = FactoryGirl.create_list(:customer, 10,
                                          user: FactoryGirl.create(:user, :customer))
      @customer = customers.sample
      Customer.reindex
      Customer.searchkick_index.refresh
    end

    it "by name" do
      search_term = @customer.name[0..2]
      expect(Customer.search(search_term)).not_to be_empty
    end

    it "by email" do
      search_term = @customer.user.email[0..2]
      expect(Customer.search(search_term)).not_to be_empty
    end
  end
end
