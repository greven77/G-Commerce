require 'rails_helper'

RSpec.describe Address, type: :model do
  let(:address)  { FactoryGirl.build :address }
  subject { address }

  it { should respond_to(:street) }
  it { should respond_to(:post_code) }
  it { should respond_to(:city) }
  it { should respond_to(:country) }
  it { should respond_to(:customer) }

  it { should validate_presence_of(:street) }
  it { should validate_presence_of(:post_code) }
  it { should validate_presence_of(:city) }
  it { should validate_presence_of(:country) }

  it { should belong_to :customer }
  it { should belong_to :country }
end
