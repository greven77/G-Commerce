require 'rails_helper'

RSpec.describe Admin::FeedbacksController, type: :controller do
  let!(:category) { FactoryGirl.create(:category) }
  let!(:product) { FactoryGirl.create(:product, category: category) }
  let!(:admin) { FactoryGirl.create(:user, :admin) }
  let!(:customer) { FactoryGirl.create(:user, :customer) }
  let!(:not_logged) { FactoryGirl.create(:user, :tokenless)}

  context "admin users" do
    describe "GET #index" do
      before do
        @feedbacks = FactoryGirl.create_list(:feedback, 55, product_id: product.id)
        @feedback = @feedbacks.sample
        @feedback_product_id = @feedback.product.id,
        @category_id = @feedback.product.category.id
      end

      it "should return 25 records only if no page or per page is specified" do
        get :index, auth_user_id: admin.id, auth_token: admin.authentication_token,
            feedback: @feedback.as_json,
            product_id: @feedback_product_id,
            category_id: @category_id
        body = JSON.parse(response.body)
        expect(body["feedbacks"].count).to eq(25)
      end

      it "should return 50 records max" do
        get :index, auth_user_id: admin.id, auth_token: admin.authentication_token,
            product_id: @feedback_product_id,
            category_id: @category_id,
            page: 1, per_page: 55
        body = JSON.parse(response.body)
        expect(body["feedbacks"].count).to eq(50)
      end

      it "should return current page" do
        get :index, auth_user_id: admin.id, auth_token: admin.authentication_token,
            product_id: @feedback_product_id,
            category_id: @category_id, page: 2, per_page: 20
        body = JSON.parse(response.body)
        expect(body["meta"]["page_count"]).to eq(3)
      end

      it "should return record count" do
        get :index, auth_user_id: admin.id, auth_token: admin.authentication_token,
            product_id: @feedback_product_id,
            category_id: @category_id,
            page: 2, per_page: 20
        body = JSON.parse(response.body)
        expect(body["meta"]["current_page"]).to eq(2)
      end

      it "should return page count" do
        get :index, auth_user_id: admin.id, auth_token: admin.authentication_token,
            product_id: @feedback_product_id,
            category_id: @category_id,
            page: 2, per_page: 20
        body = JSON.parse(response.body)
        expect(body["meta"]["current_page"]).to eq(2)
      end

      it "should return page count" do
        get :index, auth_user_id: admin.id, auth_token: admin.authentication_token,
            product_id: @feedback_product_id,
            category_id: @category_id,
            page: 2, per_page: 20
        body = JSON.parse(response.body)
        expect(body["meta"]["record_count"]).to eq(55)
      end
    end

    describe "GET #show" do
      before(:each)do
        @feedback = FactoryGirl.create(:feedback)
        @feedback_product_id = @feedback.product.id
        get :show, id: @feedback.id, auth_user_id: admin.id,
            product_id: @feedback_product_id,
            category_id: category.id,
            auth_token: admin.authentication_token
      end

      it { should respond_with 200}

      it "requires a valid feedback id", skip_before: true do
        get :show, id: 3245, auth_user_id: admin.id,
            auth_token: admin.authentication_token,
            product_id: product.id,
            category_id: product.category.id
        should respond_with 404
      end
    end

    describe "POST #create" do
      before do
        @feedback = FactoryGirl.build(:feedback).as_json
        @feedback["product_id"] = product.id
        post :create, feedback: @feedback.as_json,
             auth_user_id: admin.id,
             auth_token: admin.authentication_token,
             product_id: product.id
        @body = JSON.parse(response.body)
        puts "body #{@body}"
      end
      it { should respond_with 201}

      it "should retrieve server side generated id" do
        expect(@body["id"]).to_not eq(@feedback["id"])
      end

      it "should have a product id" do
        expect(@body["product_id"]).to eq(@feedback["product_id"])
      end

      describe "Shouldn't allow creation" do
        after(:each) do
          post :create, feedback: @feedback,
               auth_user_id: admin.id,
               auth_token: admin.authentication_token,
               product_id: product.id
          should respond_with 422
        end

        it "without comment", skip_before: true do
          @feedback = FactoryGirl.build(:feedback, :commentless).as_json
        end

        it "without rating", skip_before: true do
          @feedback = FactoryGirl.build(:feedback, :ratingless).as_json
        end
      end
    end

      describe "DELETE #destroy" do
        before(:each) do
          @feedback = FactoryGirl.create(:feedback, product: product)
          delete :destroy, id: @feedback.id, auth_user_id: admin.id,
                 auth_token: admin.authentication_token,
                 product_id: @feedback.product.id,
                 category_id: @feedback.product.category.id
        end

        it { should respond_with 204}

        it "deleted feedback should not be present" do
          expect {
               Feedback.find(@feedback.id)
             }.to raise_exception(ActiveRecord::RecordNotFound)
        end

        it "should delete image" do
          expect(File).not_to exist("#{Rails.root}@image_url")
        end
    end
  end

  context "customer users" do
    before(:each) do
      @feedback = FactoryGirl.create(:feedback, product: product)
    end

    describe "GET #show" do
      it "should not be authorized to access" do
        get :show, id: @feedback.id, auth_user_id: customer.id,
            auth_token: customer.authentication_token,
            product_id: product.id,
            category_id: category.id
        expect(response.status).to eq(401)
      end
    end

    describe "POST #create" do
      it "should not be authorized to access" do
        post :create, feedback: @feedback, auth_user_id: customer.id,
             product_id: product.id,
             auth_token: customer.authentication_token
        expect(response.status).to eq(401)
      end
    end

    describe "DELETE #destroy" do
      it "should not be authorized to access" do
        delete :destroy, id: @feedback.id, auth_user_id: customer.id,
               auth_token: customer.authentication_token,
               product_id: product.id,
               category_id: category.id
        expect(response.status).to eq(401)
      end
    end
  end

  context "not logged users" do
    before(:each) do
      @feedback = FactoryGirl.create(:feedback, product: product)
    end

    describe "GET #show" do
      it "should not be authorized to access" do
        get :show, id: @feedback.id, auth_user_id: not_logged.id,
            auth_token: nil,
            product_id: product.id
        expect(response.status).to eq(401)
      end
    end

    describe "POST #create" do
      it "should not be authorized to access" do
        post :create, feedback: @feedback, auth_user_id: not_logged.id,
             auth_token: nil, product_id: product.id
        expect(response.status).to eq(401)
      end
    end

    describe "DELETE #destroy" do
      it "should not be authorized to access" do
        delete :destroy, id: @feedback.id, auth_user_id: not_logged.id,
               auth_token: nil,
               product_id: product.id
        expect(response.status).to eq(401)
      end
    end
  end
end
