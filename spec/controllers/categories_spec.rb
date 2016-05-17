require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  let!(:admin) { FactoryGirl.create(:user, :admin) }
  let!(:customer) { FactoryGirl.create(:user, :customer) }
  let!(:not_logged) { FactoryGirl.create(:user, :tokenless)}

  context "admin users" do
    describe "GET #index" do
      before do
        @categories = FactoryGirl.create_list(:category, 10)
        get :index
      end

      it { should respond_with 200 }

      it "should contain 10 categories" do
        body = JSON.parse(response.body)
        expect(body["categories"].count).to eq(10)
      end
    end
    describe "GET #show" do
      before do
        @parent_category = FactoryGirl.create(:category)
        @category = FactoryGirl.create(:category_with_products,
                                       parent: @parent_category)
        get :show, id: @category.id
      end

      it { should respond_with 200}

      it "requires a valid category id", skip_before: true do
        get :show, id: 3245, auth_user_id: admin.id,
            auth_token: admin.authentication_token
        should respond_with 404
      end

      it "should contain 25 products" do
        response_products = JSON.parse(response.body)["products"]
        expect(response_products.count).to eq(25)
      end

      it "should have a parent category" do
        body = JSON.parse(response.body)
        expect(body["parent_id"]).to eq(@parent_category.id)
      end

      it "should be accessible via name" do
        should route(:get, "/categories/#{@category.to_param}")
                .to(action: 'show', id: @category.to_param )
      end
    end

    describe "POST #create" do
      it "should not be accessible" do
        should_not route(:post, '/categories').to(action: 'create')
      end
    end

    describe "PUT #update" do
      it "should not be accessible" do
        should_not route(:put, '/categories/1').to(action: 'update', id: 1)
      end
    end

    describe "DELETE #destroy" do
      it "should not be accessible" do
        should_not route(:delete, '/categories/1').to(action: 'destroy', id: 1)
      end
    end
  end
end
