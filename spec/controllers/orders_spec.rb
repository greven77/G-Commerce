require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  let(:customer) { FactoryGirl.create(:user, :customer) }
  let(:not_logged) { FactoryGirl.create(:user, :tokenless)}
  let(:customer_user) { FactoryGirl.create(:customer, user: customer) }
  let(:other_customer) { FactoryGirl.create(:user, :customer) }
  let(:other_customer_user) {FactoryGirl.create(:customer, user: customer)}
  let(:orders) { FactoryGirl.create_list(:order, 55, customer: customer_user ) }
  let(:sent) { FactoryGirl.create(:order_status, description: "Sent",
                                  editable_by_customer: false) }
  let(:delivered) { FactoryGirl.create(:order_status, description: "Delivered",
                                       editable_by_customer: false) }

  context "customer users" do
    describe "GET #index" do
      before do
        customer
        customer_user
        orders
      end

      it "should respond with OK status" do
        get :index, auth_user_id: customer.id, auth_token: customer.authentication_token,
            customer_id: customer_user.id
        should respond_with 200
      end

      it "should return 25 records only if no page or per page is specified" do
        get :index, auth_user_id: customer.id, auth_token: customer.authentication_token,
            customer_id: customer_user.id
        body = JSON.parse(response.body)
        expect(body["orders"].count).to eq(25)
      end

      it "should return 50 records max" do
        get :index, auth_user_id: customer.id, auth_token: customer.authentication_token,
            customer_id: customer_user.id, page: 1, per_page: 55
        body = JSON.parse(response.body)
        expect(body["orders"].count).to eq(50)
      end

      it "should return current page" do
        get :index, auth_user_id: customer.id, auth_token: customer.authentication_token,
            customer_id: customer_user.id, page: 2, per_page: 20
        body = JSON.parse(response.body)
        expect(body["meta"]["current_page"]).to eq(2)
      end

      it "should return page count" do
        get :index, auth_user_id: customer.id, auth_token: customer.authentication_token,
            customer_id: customer_user.id, page: 2, per_page: 20
        body = JSON.parse(response.body)
        expect(body["meta"]["page_count"]).to eq(3)
      end

      it "should return record count" do
        get :index, auth_user_id: customer.id, auth_token: customer.authentication_token,
            customer_id: customer_user.id, page: 2, per_page: 20
        body = JSON.parse(response.body)
        expect(body["meta"]["record_count"]).to eq(55)
      end

      it "should show only current user orders" do
        get :index, auth_user_id: customer.id, auth_token: customer.authentication_token,
            customer_id: customer_user.id

        orders = JSON.parse(response.body)["orders"]

        current_user_orders_only = orders.
          reduce(true) { |acc, order| acc && (order["customer_id"] == customer_user.id) }
        expect(current_user_orders_only).to eq(true)
      end

      it "should not be accessible by other users" do
        get :index, auth_user_id: other_customer.id,
            auth_token: other_customer.authentication_token,
            customer_id: customer_user.id
        should respond_with 401
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
        get :show, id: @order.id, auth_user_id: customer.id,
            customer_id: customer_user.id,
            auth_token: customer.authentication_token
        @body = JSON.parse(response.body)
      end

      it { should respond_with 200}

      it "requires a valid order id", skip_before: true do
        get :show, id: 3245, auth_user_id: customer.id,
            auth_token: customer.authentication_token,
            customer_id: customer_user.id
        should respond_with 404
      end

      it "should contain 5 products" do
        expect(@body["order_details"].count).to eq(5)
      end

      it "should not be accessible by other users" do
        get :show, id: @order.id, auth_user_id: other_customer.id,
            auth_token: other_customer.authentication_token,
            customer_id: customer_user.id
        should respond_with 401
      end
    end

    describe "DELETE #destroy" do
      before(:each) do
        @order = orders.sample
        delete :destroy, id: @order.id, auth_user_id: customer.id,
                 auth_token: customer.authentication_token,
                 customer_id: customer_user.id
      end

      it { should respond_with 204}

      it "deleted product should not be present" do
        expect {
          Order.find(@order.id)
           }.to raise_exception(ActiveRecord::RecordNotFound)
      end

      it "should not be accessible by other users", skip_before: true do
        order = orders.sample
        delete :destroy, id: order.id, auth_user_id: other_customer.id,
               auth_token: other_customer.authentication_token,
               customer_id: customer_user.id
        should respond_with 401
      end

      it "should not be accessible when editable_by_customer is set to false",
         skip_before: true do

        @order.update(order_status: sent)
        delete :destroy, id: @order.id, auth_user_id: customer.id,
               auth_token: customer.authentication_token,
               customer_id: customer_user.id
        should respond_with 404
      end
    end

    describe "PUT #update" do
      before do
        @order = FactoryGirl.create(:order, placements: FactoryGirl.create_list(:placement, 10))
        @old_order = @order.clone.as_json(include: [:placements])
        @order.order_status = delivered

        @order_json = @order.as_json
        new_placements = FactoryGirl.build_list(:placement, 5).as_json
        updated_placements = @order.placements[0,5].as_json.map do |placement|
          placement["quantity"] = (1..3).to_a.sample
          placement
        end
        removed_placements =  @order.placements[5,10].as_json.map do |placement|
          placement["_destroy"] = true
          placement
        end

        @order_json["placements_attributes"] = updated_placements +
                                               removed_placements +
                                               new_placements

        put :update, order: @order_json,
            id: @order_json["id"],
            auth_user_id: customer.id,
            auth_token: customer.authentication_token,
            customer_id: customer_user.id
        @body = JSON.parse(response.body)
      end

      it { should respond_with 200 }

      it "should change order status " do
        expect(@old_order["order_status"]).to_not eq(@body["order_status"])
      end

      it "should have 10 products" do
        expect(@body["order_details"].count).to eq(10)
      end

      it "should have the last 5 placements removed" do
        old_product_ids = @old_order["placements"][6,10].
                          map { |placement| placement["product_id"] }
        new_product_ids = @body["order_details"].
                          map { |order_detail| order_detail["product_id"] }
        old_products_counter = new_product_ids - old_product_ids
        expect(old_products_counter.count).to eq(new_product_ids.count)
      end

      it "should not be accessible by other users", skip_before: true do
        put :update, order: @order.as_json,
            id: @order["id"],
            auth_user_id: other_customer.id,
            auth_token: other_customer.authentication_token,
            customer_id: customer_user.id
        should respond_with 401
      end

      it "should not be accessible when editable_by_customer is set to false",
         skip_before: true do

        @order = orders.sample
        @order.update(order_status: sent)
        put :update, id: @order["id"], order: @order.as_json,
            auth_user_id: customer.id,
            auth_token: customer.authentication_token,
            customer_id: customer_user.id
        should respond_with 401
      end
    end
  end

  context "not logged users" do
    before do
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
