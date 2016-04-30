require "rails_helper"

describe Users::RegistrationsController, type: :controller do

  let!(:user) { FactoryGirl.create(:user) }

  it 'does not login with invalid credentials' do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    get 'create' #add headers with params and no token
    response.status.should eql(422)
  end

  it 'does login with valid credentials' do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    post :create,format: :json, :user => {email: "test@example.com", password: "password",
                                          password_confirmation: "password" }
    response.status.should eql(200)
  end
end
