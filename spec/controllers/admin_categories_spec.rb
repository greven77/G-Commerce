require 'rails_helper'

RSpec.describe Admin::CategoriesController, type: :controller do
  let!(:admin) { FactoryGirl.create(:user, :admin) }
  let!(:customer) { FactoryGirl.create(:user, :customer) }
  let!(:not_logged) { FactoryGirl.create(:user, :tokenless)}

  context "admin users" do
    describe "GET #show" do
      before(:each) do
        @parent_category = FactoryGirl.create(:category)
        @category = FactoryGirl.create(:category_with_products,
                                       parent: @parent_category)
        get :show, id: @category.id, auth_user_id: admin.id,
            auth_token: admin.authentication_token
      end

      it { should respond_with 200}

      it "requires a valid category id", skip_before: true do
        get :show, id: 3245, auth_user_id: admin.id,
            auth_token: admin.authentication_token
        should respond_with 404
      end

      it "should contain 5 products" do
        response_products = JSON.parse(response.body)["products"]
        expect(response_products.count).to eq(5)
      end
    end

    describe "POST #create" do
      before(:each)do
        @category = FactoryGirl.build(:category).as_json
        @category["subcategories"] =  [{"name" => "name1"}, {"name" => "name2"}]
        post :create, category: @category,
             auth_user_id: admin.id,
             auth_token: admin.authentication_token
#             params: { subcategories: @category["subcategories"] }
        @body = JSON.parse(response.body)
      end
      it { should respond_with 201}

      it "should retrieve server side generated id" do
        expect(@body["id"]).to_not eq(@category["id"])
      end

      it "should create two children" do
        expect(@body["subcategories"].count).to eq(2)
      end
    end


      describe "DELETE #destroy" do
        before(:each) do
          @categories = FactoryGirl.create_list(:category_with_products, 10)
          @category = @categories.sample
          @descendant_ids = @category.descendants.pluck(:id)
          delete :destroy, id: @category.id, auth_user_id: admin.id,
                 auth_token: admin.authentication_token
        end

        it { should respond_with 204}
        it "deleted category should not be present" do
          expect {
               Category.find(@category.id)
             }.to raise_exception(ActiveRecord::RecordNotFound)
        end

        it "should delete its subcategories" do
          expect(Category.where(id: @descendant_ids)).to be_empty
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
            auth_token: admin.authentication_token
            @body = JSON.parse(response.body)
      end

      it { should respond_with 200 }

      it "should reflect the changes made to its data" do
        expect(@body["name"]).to eq("new name")
      end

      it "should not contain the old values" do
        expect(@body["name"]).to_not eq(@old_category["name"])
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
            auth_token: customer.authentication_token
            expect(response.status).to eq(401)
      end
    end

    describe "POST #create" do
      it "should not be authorized to access" do
        post :create, category: @category, auth_user_id: customer.id,
             auth_token: customer.authentication_token
             expect(response.status).to eq(401)
      end
    end

    describe "PUT #update" do
      it "should not be authorized to access" do
        @category.name = "new name"
        @category.save
        put :update, category: @category.as_json,
            id: @category.id,
            auth_user_id: customer.id,
            auth_token: customer.authentication_token
        expect(response.status).to eq(401)
      end
    end

    describe "DELETE #destroy" do
      it "should not be authorized to access" do
        delete :destroy, id: @category.id, auth_user_id: customer.id,
               auth_token: customer.authentication_token
        expect(response.status).to eq(401)
      end
    end
  end

  context "not logged users" do

    let!(:category) { FactoryGirl.create(:category) }

    describe "GET #show" do
      it "should not be authorized to access" do
        get :show, id: category.id, auth_user_id: not_logged.id,
            auth_token: nil
            expect(response.status).to eq(401)
      end
    end

    describe "POST #create" do
      it "should not be authorized to access" do
        post :create, category: category, auth_user_id: not_logged.id,
             auth_token: nil
        expect(response.status).to eq(401)
      end
    end

    describe "PUT #update" do
      it "should not be authorized to access" do
        category.name = "new name"
        category.save
        put :update, category: category.as_json,
            id: category.id,
            auth_user_id: not_logged.id,
            auth_token: nil,
            category_name: category.name
        expect(response.status).to eq(401)
      end
    end

    describe "DELETE #destroy" do
      it "should not be authorized to access" do
        delete :destroy, id: category.id, auth_user_id: not_logged.id,
               auth_token: nil
        expect(response.status).to eq(401)
      end
    end
  end
end
