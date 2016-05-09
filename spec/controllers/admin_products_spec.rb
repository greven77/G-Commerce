require 'rails_helper'

RSpec.describe Admin::ProductsController, type: :controller do
  let!(:category) { FactoryGirl.create(:category) }
  let!(:admin) { FactoryGirl.create(:user, :admin) }
  let!(:customer) { FactoryGirl.create(:user, :customer) }
  let!(:not_logged) { FactoryGirl.create(:user, :tokenless)}
  let!(:b64image) do
    Base64.encode64(File.open(Rails.root + "spec/fixtures/files/image1.jpg", "rb").read)
  end

  context "admin users" do
    describe "GET #index" do
      before do
        @products = FactoryGirl.create_list(:product_with_feedback, 150)
      end

      it "should return 25 records only if no page or per page is specified"

      it "should return 100 records max"

      it "should return current page"

      it "should return page count"

      it "should return record count"
    end

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
      before do
        @product = FactoryGirl.build(:product).as_json.except("image")
        @product["image_url"] = "data:image/jpg;base64,#{b64image}"
        post :create, product: @product.as_json,
             auth_user_id: admin.id,
             auth_token: admin.authentication_token,
             category_id: category.id
        @body = JSON.parse(response.body)
      end
      it { should respond_with 201}

      it "should retrieve server side generated id" do
        expect(@body["id"]).to_not eq(@product["id"])
      end

      it "should have a image url" do
        expect(@body["image_url"]).to_not be_empty
      end

      it "should have a image physically" do
        expect(File).to exist("#{Rails.root}/public/#{@body["image_url"]}")
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
    end

      describe "DELETE #destroy" do
        before(:each) do
          @product = FactoryGirl.create(:product_with_feedback)
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

        it "should delete image" do
          expect(File).not_to exist("#{Rails.root}@image_url")
        end
    end

    describe "PUT #update" do
      let!(:b64image_2) do
        Base64.encode64(File.open(Rails.root + "spec/fixtures/files/image2.jpg", "rb").read)
      end

      before do
        @product = FactoryGirl.create(:product_with_feedback, :with_image)
        @old_product = @product.clone.as_json
        @product = @product.as_json.except("image")
        @product["name"] = "new name"
        @product["description"] = "new lorem ip"
        @product["image_url"] = "data:image/jpg;base64,#{b64image_2}"
        
        put :update, product: @product,
            id: @product["id"],
            auth_user_id: admin.id,
            auth_token: admin.authentication_token,
            category_id: category.id
        @body = JSON.parse(response.body)
      end

      it { should respond_with 200 }

      it "should not contain the old values" do
        @old_product = @old_product.except("created_at", "updated_at", "image")
        @body = @body.except("feedbacks", "created_at", "updated_at", "image_url")
        expect(@body).to_not eq(@old_product)
      end

      it "should update image_url" do
        expect(@old_product["image_url"]).to_not eq(@body["image_url"])
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
