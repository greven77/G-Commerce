require 'rails_helper'

RSpec.describe Admin::ProductsController, type: :controller do
  let!(:admin) { FactoryGirl.create(:user, :admin) }
  let!(:customer) { FactoryGirl.create(:user, :customer) }
  let!(:not_logged) { FactoryGirl.create(:user, :tokenless)}

  context "admin users" do
    describe "GET #show" do
      before(:each)do
        @product = FactoryGirl.create(:product)
        get :show, id: @product.id, auth_user_id: admin.id,
            auth_token: admin.authentication_token
      end

      it { should respond_with 200}

      it "requires a valid product id", skip_before: true do
        get :show, id: 3245, auth_user_id: admin.id,
            auth_token: admin.authentication_token
        expect(response.status).to eq(404)
      end
    end

    describe "POST #create" do
      before(:each)do
        @product = FactoryGirl.create(:product)
        post :create, product: @product.as_json,
             auth_user_id: admin.id,
             auth_token: admin.authentication_token
      end
      it { should respond_with 201}

      it "should retrieve server side generated id" do
        body = JSON.parse(response.body)
        expect(body["id"]).to_not eq(@product.id)
      end

      describe "Shouldn't allow creation" do
        after(:each) do
          post :create, product: @product,
               auth_user_id: admin.id,
               auth_token: admin.authentication_token
          should respond_with 422
        end

        it "without a name", skip_before: true do
          @product = FactoryGirl.create(:product, :nameless).as_json
        end

        it "without a price", skip_before: true do
          @product = FactoryGirl.create(:product, :priceless).as_json
        end
      end
    end
  end

  context "customer users" do
    before(:each) do
      @product = FactoryGirl.create(:product)
    end

    describe "GET #show" do
      it "should not be authorized to access" do
        get :show, id: @product.id, auth_user_id: customer.id,
            auth_token: customer.authentication_token
        expect(response.status).to eq(401)
      end
    end

    describe "POST #create" do
      it "should not be authorized to access" do
        post :create, product: @product, auth_user_id: customer.id,
             auth_token: customer.authentication_token
        expect(response.status).to eq(401)
      end
    end
  end

  context "not logged users" do
    before(:each) do
      @product = FactoryGirl.create(:product)
    end

    describe "GET #show" do
      it "should not be authorized to access" do
        get :show, id: @product.id, auth_user_id: not_logged.id,
            auth_token: nil
        expect(response.status).to eq(401)
      end
    end

    describe "POST #create" do
      it "should not be authorized to access" do
        post :create, product: @product, auth_user_id: not_logged.id,
             auth_token: nil
        expect(response.status).to eq(401)
      end
    end
  end
end
