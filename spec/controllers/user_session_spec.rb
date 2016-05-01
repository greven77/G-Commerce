require "rails_helper"

describe Users::SessionsController, type: :controller do

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:customer) { FactoryGirl.create(:user, :customer) }

  it "logs in" do
    post :create, :user => { email: customer.email, password: customer.password }
    response.status.should eql(200)
  end

  it "requires valid credentials to login" do
    post :create, :user => { email: "invalid@email.com", password: "invalid" }
    body = JSON.parse(response.body)
    expect(body["info"]).to eq("Login failed")
    response.status.should eql(401)
  end

  it "logs out" do
    delete :destroy, :user => { id: customer.id }
    body = JSON.parse(response.body)
    expect(body["info"]).to eq("Logged out")
    response.status.should eql(200)
  end

  it "requires id to logout" do
    delete :destroy, :user => { email: customer.email, password: customer.password }
    response.status.should eql(401)
  end

  it "requires a valid id to logout" do
    delete :destroy, :user => { id: 234278 }
    response.status.should eql(401)
  end
end
