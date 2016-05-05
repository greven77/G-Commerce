require "rails_helper"

describe Users::RegistrationsController, type: :controller do

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  it 'does not register with empty credentials' do
    post :create
    should respond_with 422
  end

  it 'does not register with invalid email' do
    post :create, format: :json, :user => {email: "beb", password: "password",
                                           password_confirmation: "password"}
    should respond_with 422
  end

  it 'does register with valid credentials' do
    post :create,format: :json, :user => {email: "bob@example.com", password: "password",
                                          password_confirmation: "password" }
     should respond_with 200
  end

  it 'does not register with invalid password confirmation' do
    post :create,format: :json, :user => {email: "bob@example.com", password: "password",
                                          password_confirmation: "pass" }
    should respond_with 422
  end
end
