require 'rails_helper'

RSpec.describe Admin::OrdersController, type: :controller do
  let(:admin) { FactoryGirl.create(:user, :admin) }
  let(:customer) { FactoryGirl.create(:user, :customer) }
  let(:not_logged) { FactoryGirl.create(:user, :tokenless)}
  let(:customer_user) { FactoryGirl.create(:customer, user: customer) }
  let(:orders) { FactoryGirl.create_list(:order, 55, customer: customer_user ) }

  context "admin users" do
    describe "GET #index" do
      before do
        customer_user
        orders
      end

      it "should respond with OK status" do
        get :index, auth_user_id: admin.id, auth_token: admin.authentication_token,
            customer_id: customer_user.id
        should respond_with 200
      end

      it "should return 25 records only if no page or per page is specified" do
        get :index, auth_user_id: admin.id, auth_token: admin.authentication_token,
            customer_id: customer_user.id
        body = JSON.parse(response.body)
        expect(body["orders"].count).to eq(25)
      end

      it "should return 50 records max" do
        get :index, auth_user_id: admin.id, auth_token: admin.authentication_token,
            customer_id: customer_user.id, page: 1, per_page: 55
        body = JSON.parse(response.body)
        expect(body["orders"].count).to eq(50)
      end

      it "should return current page" do
        get :index, auth_user_id: admin.id, auth_token: admin.authentication_token,
            customer_id: customer_user.id, page: 2, per_page: 20
        body = JSON.parse(response.body)
        expect(body["meta"]["current_page"]).to eq(2)
      end

      it "should return page count" do
        get :index, auth_user_id: admin.id, auth_token: admin.authentication_token,
            customer_id: customer_user.id, page: 2, per_page: 20
        body = JSON.parse(response.body)
        expect(body["meta"]["page_count"]).to eq(3)
      end

      it "should return record count" do
        get :index, auth_user_id: admin.id, auth_token: admin.authentication_token,
            customer_id: customer_user.id, page: 2, per_page: 20
        body = JSON.parse(response.body)
        expect(body["meta"]["record_count"]).to eq(55)
      end
    end

    describe "GET #show" do
      before do
        products = FactoryGirl.create_list(:product, 5)
        product_ids_and_quantities = products.map do |product|
          [product.id, (1..10).to_a.sample]
        end
        @order = orders.sample
        @order.build_placements(product_ids_and_quantities)
        @order.save
        get :show, id: @order.id, auth_user_id: admin.id,
            customer_id: customer_user.id,
            auth_token: admin.authentication_token
        @body = JSON.parse(response.body)
      end

      it { should respond_with 200}

      it "requires a valid order id", skip_before: true do
        get :show, id: 3245, auth_user_id: admin.id,
            auth_token: admin.authentication_token,
            customer_id: customer_user.id
        should respond_with 404
      end

      it "should contain 5 products" do
        expect(@body["order_details"].count).to eq(5)
      end
    end

    describe "DELETE #destroy" do
      before(:each) do
        @order = orders.sample
        delete :destroy, id: @order.id, auth_user_id: admin.id,
                 auth_token: admin.authentication_token,
                 customer_id: customer_user.id
      end

      it { should respond_with 204}

      it "deleted product should not be present" do
        expect {
          Order.find(@order.id)
           }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    describe "PUT #update" do
      let!(:cancelled) { FactoryGirl.create(:order_status, description: "Cancelled") }
      let!(:paid) { FactoryGirl.create(:order_status, description: "Paid") }
      let!(:delivered) { FactoryGirl.create(:order_status, description: "Delivered") }

      before do
        @order = orders.sample
        @old_order = @order.clone.as_json
        @order.order_status = delivered
        @order = @order.as_json

        put :update, order: @order,
            id: @order["id"],
            auth_user_id: admin.id,
            auth_token: admin.authentication_token,
            customer_id: customer_user.id
        @body = JSON.parse(response.body)
      end

      it { should respond_with 200 }

      it "should change order status " do
        expect(@old_order["order_status"]).to_not eq(@body["order_status"])
      end
    end
  end

  context "customer users" do
    before do
      @order = FactoryGirl.create(:order)
    end

    describe "GET #show" do
      it "should not be authorized to access" do
        get :show, id: @order.id, auth_user_id: customer.id,
            auth_token: customer.authentication_token,
            customer_id: customer_user.id
        expect(response.status).to eq(401)
      end
    end

    describe "PUT #update" do
      it "should not be authorized to access" do
        put :update, order: @order.as_json,
            id: @order.id,
            auth_user_id: customer.id,
            auth_token: customer.authentication_token,
            customer_id: customer_user.id
        expect(response.status).to eq(401)
      end
    end

    describe "DELETE #destroy" do
      it "should not be authorized to access" do
        delete :destroy, id: @order.id, auth_user_id: customer.id,
               auth_token: customer.authentication_token,
               customer_id: customer_user.id
        expect(response.status).to eq(401)
      end
    end
  end

  context "not logged users" do
    before(:each) do
      @order = FactoryGirl.create(:order)
    end

    describe "GET #show" do
      it "should not be authorized to access" do
        get :show, id: @order.id, auth_user_id: not_logged.id,
            auth_token: nil,
            customer_id: customer_user.id
        expect(response.status).to eq(401)
      end
    end

    describe "PUT #update" do
      it "should not be authorized to access" do
        put :update, order: @order.as_json,
            id: @order.id,
            auth_user_id: not_logged.id,
            auth_token: nil,
            customer_id: customer_user.id
        expect(response.status).to eq(401)
      end
    end

    describe "DELETE #destroy" do
      it "should not be authorized to access" do
        delete :destroy, id: @order.id, auth_user_id: not_logged.id,
               auth_token: nil,
               customer_id: customer_user.id
        expect(response.status).to eq(401)
      end
    end
  end
end
