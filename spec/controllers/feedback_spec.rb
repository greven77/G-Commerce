require 'rails_helper'

RSpec.describe FeedbacksController, type: :controller do
  let!(:customer) { FactoryGirl.create(:user, :customer) }

  describe "GET #index" do
    before do
      category = FactoryGirl.create(:category)
      product = FactoryGirl.create(:product, category: category)
      @feedbacks = FactoryGirl.create_list(:feedback, 55, product: product)
      @feedback_product_id = product.id
      @feedback_category_id = category.id
    end

    it "should return 50 records max" do
      get :index, category_id: @feedback_category_id,
          product_id: @feedback_product_id,
          page: 1, per_page: 55
      body = JSON.parse(response.body)
      expect(body["feedbacks"].count).to eq(50)
    end

    it "should return current page" do
      get :index, category_id: @feedback_category_id,
          product_id: @feedback_product_id,
          page: 2, per_page: 20
      body = JSON.parse(response.body)
      expect(body["meta"]["current_page"]).to eq(2)
    end

    it "should return page count" do
      get :index, category_id: @feedback_category_id,
          product_id: @feedback_product_id,
          page: 2, per_page: 20
      body = JSON.parse(response.body)
      expect(body["meta"]["page_count"]).to eq(3)
    end

    it "should return record count" do
      get :index, category_id: @feedback_category_id,
          product_id: @feedback_product_id,
          page: 2, per_page: 20
      body = JSON.parse(response.body)
      expect(body["meta"]["record_count"]).to eq(55)
    end
  end

  describe "GET #show" do
    it "should not be accessible" do
      should_not route(:get, 'categories/1/products/1/feedbacks/1').to(action: 'show', id: 1)
    end
  end

  describe "POST #create" do
    before do
      category = FactoryGirl.create(:category)
      product = FactoryGirl.create(:product, category: category)
      @feedback = FactoryGirl.build(:feedback, product: product)
      @feedback_product_id = product.id
      @feedback_category_id = category.id
      @feedback_user_id = @feedback.customer.user.id
      @feedback_user_auth_token = @feedback.customer.user.authentication_token
    end

    it "should not be accessible by non-logged users" do
      post :create, category_id: @feedback_category_id,
           product_id: @feedback_product_id,
           auth_user_id: nil, auth_token: nil,
           feedback: @feedback.as_json
      should respond_with 401
    end

    it "should be accessible by current user" do
      post :create, category_id: @feedback_category_id,
           product_id: @feedback_product_id,
           auth_user_id: @feedback_user_id,
           auth_token: @feedback_user_auth_token,
           feedback: @feedback.as_json
      should respond_with 201
    end

    it "should not be accessible by other customers" do
      other_customer = FactoryGirl.create(:user, :customer)
      post :create, category_id: @feedback_category_id,
           product_id: @feedback_product_id,
           auth_user_id: @feedback_user_id,
           auth_token: other_customer.authentication_token,
           feedback: @feedback.as_json
      should respond_with 401
    end
  end

  describe "PUT #update" do
    it "should not be accessible" do
      should_not route(:put, 'categories/1/products/1/feedbacks/1').to(action: 'update', id: 1)
    end
  end

  describe "DELETE #destroy" do
    before do
      @category = FactoryGirl.create(:category)
      @product = FactoryGirl.create(:product, category: @category)
    end

    before(:each) do
      @feedback = FactoryGirl.create(:feedback, product: @product)
      @feedback_product_id = @product.id
      @feedback_category_id = @category.id
      @feedback_user_id = @feedback.customer.user.id
      @feedback_user_auth_token = @feedback.customer.user.authentication_token
    end

    it "should not be accessible by non-logged users" do
      delete :destroy, category_id: @feedback_category_id,
           product_id: @feedback_product_id,
           auth_user_id: nil, auth_token: nil,
           id: @feedback.id
      should respond_with 401
    end

    it "should be accessible by author" do
      delete :destroy, category_id: @feedback_category_id,
             product_id: @feedback_product_id,
             auth_user_id: @feedback_user_id,
             auth_token: @feedback_user_auth_token,
             id: @feedback.id
      should respond_with 204
    end

    it "should be accessible by admin" do
      admin = FactoryGirl.create(:user, :admin)
      delete :destroy, category_id: @feedback_category_id,
             product_id: @feedback_product_id,
             auth_user_id: admin.id,
             auth_token: admin.authentication_token,
             id: @feedback.id
      should respond_with 204
    end

    it "should not be accessible by other customers" do
      other_customer = FactoryGirl.create(:user, :customer)
      delete :destroy, category_id: @feedback_category_id,
             product_id: @feedback_product_id,
             auth_user_id: other_customer.id,
             auth_token: other_customer.authentication_token,
             id: @feedback.id
      should respond_with 401
    end

    it "should not be present when deleted" do
      delete :destroy, category_id: @feedback_category_id,
             product_id: @feedback_product_id,
             auth_user_id: @feedback_user_id,
             auth_token: @feedback_user_auth_token,
             id: @feedback.id

      expect {
        Feedback.find(@feedback.id)
      }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
