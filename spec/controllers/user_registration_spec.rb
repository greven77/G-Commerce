require "rails_helper"

describe Users::RegistrationsController, type: :controller do

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  it 'does not register with empty credentials' do
    post :create
    response.status.should eql(422)
  end

  it 'does not register with invalid email' do
    post :create, format: :json, :user => {email: "beb", password: "password",
                                           password_confirmation: "password"}
    response.status.should eql(422)
  end

  it 'does register with valid credentials' do
    post :create,format: :json, :user => {email: "bob@example.com", password: "password",
                                          password_confirmation: "password" }
    response.status.should eql(200)
    # puts response.body
  end

  it 'does not register with invalid password confirmation' do
    post :create,format: :json, :user => {email: "bob@example.com", password: "password",
                                          password_confirmation: "pass" }
    response.status.should eql(422)
  end
end
