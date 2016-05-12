require 'rails_helper'

RSpec.describe User, :type => :model do
  it { should belong_to :role }
  it { should validate_presence_of :password_confirmation }
  it { should have_many(:orders) }

  context "triggering callbacks" do
    before(:each) do
      @user = User.new(email: "user@example.com", password: "password",
                       password_confirmation: "password")
    end

    it "triggers default role assignment" do
      expect(@user).to receive(:set_default_role)
      @user.save
    end

    it "triggers token creation" do
      expect(@user).to receive(:ensure_authentication_token)
      @user.save
    end
  end

  context "checking if callbacks set proper values on creation" do
    before(:each) do
      @user = FactoryGirl.create(:user, :customer)
    end

    it "sets authentication  token" do
      expect(@user.authentication_token).to be
    end
  end
end
