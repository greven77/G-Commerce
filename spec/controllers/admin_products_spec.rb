require 'rails_helper'

RSpec.describe Admin::ProductsController, type: :controller do
  let!(:category) { FactoryGirl.create(:category) }
  let!(:admin) { FactoryGirl.create(:user, :admin) }
  let!(:customer) { FactoryGirl.create(:user, :customer) }
  let!(:not_logged) { FactoryGirl.create(:user, :tokenless)}

  context "admin users" do
    describe "GET #show" do
      before(:each)do
        @product = FactoryGirl.create(:product_with_feedback)
        get :show, id: @product.id, auth_user_id: admin.id,
            category_id: category.id,
            auth_token: admin.authentication_token
      end

      it { should respond_with 200}

      it "requires a valid product id", skip_before: true do
        get :show, id: 3245, auth_user_id: admin.id,
            auth_token: admin.authentication_token,
            category_id: category.id
        should respond_with 404
      end

      it "should contain 5 feedbacks" do
        expect(@product.feedbacks.count).to eq(5)
      end
    end

    describe "POST #create" do
      before(:each)do
        @product = FactoryGirl.build(:product)
        post :create, product: @product.as_json,
             auth_user_id: admin.id,
             auth_token: admin.authentication_token,
             category_id: category.id
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
               auth_token: admin.authentication_token,
               category_id: category.id
          should respond_with 422
        end

        it "without a name", skip_before: true do
          @product = FactoryGirl.create(:product, :nameless).as_json
        end

        it "without a price", skip_before: true do
          @product = FactoryGirl.create(:product, :priceless).as_json
        end
      end

      describe "DELETE #destroy" do
        before(:each) do
          @products = FactoryGirl.create_list(:product, 10)
          @product = @products.sample
          delete :destroy, id: @product.id, auth_user_id: admin.id,
                 auth_token: admin.authentication_token,
                 category_id: category.id
        end

        it { should respond_with 204}
        it "deleted product should not be present" do
          expect {
               Product.find(@product.id)
             }.to raise_exception(ActiveRecord::RecordNotFound)
        end
      end
    end

    describe "PUT #update" do
      before(:each) do
        @product = FactoryGirl.create(:product_with_feedback)
        @old_product = @product.clone.as_json
        @product.name = "new name"
        @product.description = "new lorem ip"
        @product.save
        put :update, product: @product.as_json,
            id: @product.id,
            auth_user_id: admin.id,
            auth_token: admin.authentication_token,
            category_id: category.id
        @body = JSON.parse(response.body)
      end

      it { should respond_with 200 }

      it "should reflect the changes made to its data" do
        @product = @product.as_json.except("created_at", "updated_at")
        @body = @body.except("feedbacks","created_at", "updated_at")
        expect(@body).to eq(@product)
      end

      it "should not contain the old values" do
        @old_product = @old_product.except("created_at", "updated_at")
        @body = @body.except("feedbacks", "created_at", "updated_at")
        expect(@body).to_not eq(@old_product)
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
            auth_token: customer.authentication_token,
            category_id: category.id
        expect(response.status).to eq(401)
      end
    end

    describe "POST #create" do
      it "should not be authorized to access" do
        post :create, product: @product, auth_user_id: customer.id,
             auth_token: customer.authentication_token,
             category_id: category.id
        expect(response.status).to eq(401)
      end
    end

    describe "PUT #update" do
      it "should not be authorized to access" do
        @product.name = "new name"
        @product.description = "new lorem ip"
        @product.save
        put :update, product: @product.as_json,
            id: @product.id,
            auth_user_id: customer.id,
            auth_token: customer.authentication_token,
            category_id: category.id
        expect(response.status).to eq(401)
      end
    end

    describe "DELETE #destroy" do
      it "should not be authorized to access" do
        delete :destroy, id: @product.id, auth_user_id: customer.id,
               auth_token: customer.authentication_token,
               category_id: category.id
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
            auth_token: nil,
            category_id: category.id
        expect(response.status).to eq(401)
      end
    end

    describe "POST #create" do
      it "should not be authorized to access" do
        post :create, product: @product, auth_user_id: not_logged.id,
             auth_token: nil,
              category_id: category.id
        expect(response.status).to eq(401)
      end
    end

    describe "PUT #update" do
      it "should not be authorized to access" do
        @product.name = "new name"
        @product.description = "new lorem ip"
        @product.save
        put :update, product: @product.as_json,
            id: @product.id,
            auth_user_id: not_logged.id,
            auth_token: nil,
            category_id: category.id
        expect(response.status).to eq(401)
      end
    end

    describe "DELETE #destroy" do
      it "should not be authorized to access" do
        delete :destroy, id: @product.id, auth_user_id: not_logged.id,
               auth_token: nil,
               category_id: category.id
        expect(response.status).to eq(401)
      end
    end
  end
end
