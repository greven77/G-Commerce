require 'rails_helper'

RSpec.describe CustomersController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:customer_user) { FactoryGirl.create(:user, :customer) }
  let!(:not_logged_user) { FactoryGirl.create(:user, :tokenless) }

  context "customer users" do
    describe "GET #index" do
      it "should not be accessible" do
        should_not route(:get, '/customers').to(action: 'index')
      end
    end

    describe "DELETE #destroy" do
      it "should not be accessible" do
        should_not route(:delete, '/customers/1').to(action: 'destroy', id: 1)
      end
    end

    describe "GET #show" do
      before do
        @customer = FactoryGirl.create(:customer_with_feedback, user: customer_user)
        get :show, id: @customer.id, auth_user_id: customer_user.id,
            auth_token: customer_user.authentication_token
      end

      it { should respond_with 200}

      it "requires a valid product id", skip_before: true do
        get :show, id: 3245, auth_user_id: customer_user.id,
            auth_token: customer_user.authentication_token
        should respond_with 404
      end

      it "should contain 5 feedbacks" do
        expect(@customer.feedbacks.count).to eq(5)
      end

      it "should not be acessible by other users" do
        @customer_user_2 = FactoryGirl.create(:user, :customer)
        get :show, id: @customer.id, auth_user_id: @customer_user_2.id,
            auth_token: @customer_user_2.authentication_token
        should respond_with 401
      end
    end

    describe "POST #create" do
      before do
        @customer = FactoryGirl.build(:customer)
                    .as_json(include:
                               [:shipping_address, :billing_address,
                                :payment_method])
        @customer["shipping_address_attributes"] = @customer["shipping_address"].except("id")
        @customer["billing_address_attributes"] = @customer["billing_address"].except("id")
        @customer["payment_method_attributes"] = @customer["payment_method"].except("id")

        post :create, customer: @customer,
             auth_user_id: customer_user.id,
             auth_token: customer_user.authentication_token
        @body = JSON.parse(response.body)
      end
      it { should respond_with 201}

      it "should retrieve server side generated id" do
        expect(@body["id"]).to_not eq(@customer["id"])
      end

      describe "Validation" do
        after(:each) do
          should respond_with 422
        end
        context "when payment_method is not provided" do
          it 'return an error as response' do
            post :create, customer: @customer.except["payment_method_attributes"],
             auth_user_id: customer_user.id,
             auth_token: customer_user.authentication_token
          end
        end

        context "when shipping_address is not provided" do
          it 'return an error as response' do
            post :create, customer: @customer.except["shipping_address_attributes"],
             auth_user_id: customer_user.id,
             auth_token: customer_user.authentication_token
          end
        end

        context "when billing_address is not provided" do
          it 'returns an error as response' do
            post :create, customer: @customer.except["billing_address_attributes"],
             auth_user_id: customer_user.id,
             auth_token: customer_user.authentication_token
          end
        end
      end
    end

    describe "PUT #update" do
      before do
        @customer = FactoryGirl.create(:customer, user: customer_user).as_json(include:
                               [:shipping_address, :billing_address,
                                :payment_method])
        @customer["shipping_address_attributes"] = @customer["shipping_address"].except("id")
        @customer["billing_address_attributes"] = @customer["billing_address"].except("id")
        @customer["payment_method_attributes"] = @customer["payment_method"].except("id")
        @old_customer = @customer.clone
        @customer["name"] = "new name"
        @customer["phone"] = "420666"
        @customer["shipping_address_attributes"]["street"] = "shipping new street"
        @customer["billing_address_attributes"]["street"] = "billing new street"
        @customer["payment_method_attributes"]["card_number"] = "6664206664206664"

        put :update, customer: @customer,
            id: @customer["id"],
            auth_user_id: customer_user.id,
            auth_token: customer_user.authentication_token
        @body = JSON.parse(response.body)

      end

      it { should respond_with 200 }

      it "should not contain the old values" do
        @old_customer = @old_customer.except("created_at", "updated_at")
        @body = @body.except("created_at", "updated_at")
        expect(@body).to_not eq(@old_customer)
      end

      it "should respond with updated name" do
        expect(@body["name"]).to eq(@customer["name"])
      end

      it "should respond with updated phone" do
        expect(@body["phone"]).to eq(@customer["phone"])
      end

      it "should respond with updated shipping address" do
        expect(@body["shipping_address"]["street"])
          .to eq(@customer["shipping_address_attributes"]["street"])
      end

      it "should respond with updated billing address" do
        expect(@body["billing_address"]["street"])
          .to eq(@customer["billing_address_attributes"]["street"])
      end

      it "should respond with updated payment method" do
        expect(@body["payment_method"]["card_number"])
          .to eq(@customer["payment_method_attributes"]["card_number"])
      end
    end
  end

  context "not logged users" do
    before(:each) do
      @customer = FactoryGirl.create(:product)
    end

    describe "GET #show" do
      it "should not be authorized to access" do
        get :show, id: @customer.id, auth_user_id: not_logged_user.id,
            auth_token: nil
        expect(response.status).to eq(401)
      end
    end

    describe "POST #create" do
      it "should not be authorized to access" do
        post :create, customer: @customer, auth_user_id: not_logged_user.id,
             auth_token: nil
        expect(response.status).to eq(401)
      end
    end

    describe "PUT #update" do
      it "should not be authorized to access" do
        @customer.name = "new name"
        @customer.save
        put :update, product: @customer.as_json,
            id: @customer.id,
            auth_user_id: not_logged_user.id,
            auth_token: nil
        expect(response.status).to eq(401)
      end
    end
  end
end
