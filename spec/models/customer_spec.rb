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
end
