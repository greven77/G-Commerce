require 'rails_helper'

RSpec.describe Payment, type: :model do
  let(:payment)  { FactoryGirl.build :payment }
  subject { payment }

  it { should respond_to(:card_type) }
  it { should respond_to(:card_number) }
  it { should respond_to(:valid_until) }
  it { should respond_to(:verification_code) }
  it { should respond_to(:customer) }

  it { should validate_presence_of(:card_type) }
  it { should validate_presence_of(:card_number) }
  it { should validate_presence_of(:verification_code) }
  it { should allow_value(Faker::Business.credit_card_expiry_date.strftime("%m/%y")).for(:valid_until) }
  it { should_not allow_value("02/01").for(:valid_until) }
  it { should_not allow_value("91/73").for(:valid_until) }
  it { should allow_value(Faker::Number.number(3)).for(:verification_code) }
  it { should_not allow_value(Faker::Number.number(2)).for(:verification_code) }
  it { should_not allow_value(Faker::Number.number(5)).for(:verification_code) }

  it { should belong_to :customer }
end
