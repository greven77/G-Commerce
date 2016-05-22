require 'rails_helper'

RSpec.describe User, :type => :model do
  it { should belong_to :role }
  it { should validate_presence_of :password_confirmation }

  context "triggering callbacks" do
    before(:each) do
      @user = User.new(email: "user@example.com", password: "password",
                       password_confirmation: "password")
      User.reindex
      User.searchkick_index.refresh
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

  context "search" do
    before do
      users = FactoryGirl.create_list(:user, 10, :customer)
      @user = users.sample
      User.reindex
      User.searchkick_index.refresh
    end

    it "by email" do
      search_term = @user.email[0..2]
      expect(User.search(search_term)).not_to be_empty
    end

    it "by role name" do
      search_term = @user.user_role[0..2]
      expect(User.search(search_term)).not_to be_empty
    end
  end
end
