require 'rails_helper'

RSpec.describe Admin::CategoriesController, type: :controller do
  let!(:admin) { FactoryGirl.create(:user, :admin) }
  let!(:customer) { FactoryGirl.create(:user, :customer) }
  let!(:not_logged) { FactoryGirl.create(:user, :tokenless)}

  context "admin users" do
    describe "GET #show" do
      before(:each)do
        @parent_category = FactoryGirl.create(:category)
        @category = FactoryGirl.create(:category_with_products,
                                       parent_id: @parent_category.id)
        get :show, name: @category.name, auth_user_id: admin.id,
            category_name: category.name,
            auth_token: admin.authentication_token
      end

      it { should respond_with 200}

      it "requires a valid category id", skip_before: true do
        get :show, id: 3245, auth_user_id: admin.id,
            auth_token: admin.authentication_token,
            category_id: category.id
        should respond_with 404
      end

      it "should contain 5 products" do
        response_products = JSON.parse(response.body["products"])
        expect(response_products.count).to eq(5)
      end
    end

    describe "POST #create" do
      before(:each)do
        @category = FactoryGirl.create(:category)
        post :create, category: @category.as_json,
             auth_user_id: admin.id,
             auth_token: admin.authentication_token,
             category_id: category.id
      end
      it { should respond_with 201}

      it "should retrieve server side generated id" do
        body = JSON.parse(response.body)
        expect(body["id"]).to_not eq(@category.id)
      end


      describe "DELETE #destroy" do
        before(:each) do
          @categories = FactoryGirl.create_list(:category, 10)
          @category = @categories.sample
          delete :destroy, id: @category.id, auth_user_id: admin.id,
                 auth_token: admin.authentication_token,
                 category_id: category.id
        end

        it { should respond_with 204}
        it "deleted category should not be present" do
          expect {
               Category.find(@category.id)
             }.to raise_exception(ActiveRecord::RecordNotFound)
        end
      end
    end

    describe "PUT #update" do
      before(:each) do
        @category = FactoryGirl.create(:category)
        @old_category = @category.clone.as_json
        @category.name = "new name"
        @category.save
        put :update, category: @category.as_json,
            id: @category.id,
            auth_user_id: admin.id,
            auth_token: admin.authentication_token,
            category_id: category.id
        @body = JSON.parse(response.body)
      end

      it { should respond_with 200 }

      it "should reflect the changes made to its data" do
        @category = @category.as_json.except("created_at", "updated_at")
        @body = @body.except("created_at", "updated_at")
        expect(@body).to eq(@category)
      end

      it "should not contain the old values" do
        @old_category = @old_category.except("created_at", "updated_at")
        @body = @body.except("created_at", "updated_at")
        expect(@body).to_not eq(@old_category)
      end
    end
  end

  context "customer users" do
    before(:each) do
      @category = FactoryGirl.create(:category)
    end

    describe "GET #show" do
      it "should not be authorized to access" do
        get :show, id: @category.id, auth_user_id: customer.id,
            auth_token: customer.authentication_token,
            category_id: category.id
        expect(response.status).to eq(401)
      end
    end

    describe "POST #create" do
      it "should not be authorized to access" do
        post :create, category: @category, auth_user_id: customer.id,
             auth_token: customer.authentication_token,
             category_id: category.id
        expect(response.status).to eq(401)
      end
    end

    describe "PUT #update" do
      it "should not be authorized to access" do
        @category.name = "new name"
        @category.description = "new lorem ip"
        @category.save
        put :update, category: @category.as_json,
            id: @category.id,
            auth_user_id: customer.id,
            auth_token: customer.authentication_token,
            category_id: category.id
        expect(response.status).to eq(401)
      end
    end

    describe "DELETE #destroy" do
      it "should not be authorized to access" do
        delete :destroy, id: @category.id, auth_user_id: customer.id,
               auth_token: customer.authentication_token,
               category_id: category.id
        expect(response.status).to eq(401)
      end
    end
  end

  context "not logged users" do
    before(:each) do
      @category = FactoryGirl.create(:category)
    end

    describe "GET #show" do
      it "should not be authorized to access" do
        get :show, id: @category.id, auth_user_id: not_logged.id,
            auth_token: nil,
            category_id: category.id
        expect(response.status).to eq(401)
      end
    end

    describe "POST #create" do
      it "should not be authorized to access" do
        post :create, category: @category, auth_user_id: not_logged.id,
             auth_token: nil,
              category_id: category.id
        expect(response.status).to eq(401)
      end
    end

    describe "PUT #update" do
      it "should not be authorized to access" do
        @category.name = "new name"
        @category.save
        put :update, category: @category.as_json,
            id: @category.id,
            auth_user_id: not_logged.id,
            auth_token: nil,
            category_id: category.id
        expect(response.status).to eq(401)
      end
    end

    describe "DELETE #destroy" do
      it "should not be authorized to access" do
        delete :destroy, id: @category.id, auth_user_id: not_logged.id,
               auth_token: nil,
               category_id: category.id
        expect(response.status).to eq(401)
      end
    end
  end
end
