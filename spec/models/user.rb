require 'rails_helper'
#it 'should generate a user token' do
#   post :create, format: :json, :user => {email: "bob@example.com", password: "password",
#password_confirmation: "password"}
#   u = User.find_by_email("bob@example.com")
#    expect(u.authentication_token).not_to be_nil
#    expect(u.authentication_token).not_to be_empty
#  end

#  it 'should assign registered role by default' do
#    post :create, format: :json, :user => {email: "bob@example.com", password: "password",
#                                           password_confirmation: "password"}
#    u = User.find_by_email("bob@example.com")
#    role = u.role.name
#    expect(role).to be
#  end
describe User, 'association' do
  it { should belong_to(:role) }
end

describe User, 'validation' do
  it { should validate_presence_of(:password_confirmation) }
end

RSpec.describe User, :type => :model do
  user = Factory
end
