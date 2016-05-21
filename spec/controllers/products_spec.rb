require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  let!(:category) { FactoryGirl.create(:category) }
  let!(:customer) { FactoryGirl.create(:user, :customer) }
  let!(:not_logged) { FactoryGirl.create(:user, :tokenless)}

  describe "GET #index" do
    before do
      category = FactoryGirl.create(:category)
      @products = FactoryGirl.create_list(:product, 55, category_id: category.id)
      @product = @products.sample
      @product_category_id = @product.category.id
      @products.each { |product| product.reindex }
      Product.searchkick_index.refresh
    end

    it "should return 25 records only if no page or per page is specified" do
      get :index, category_id: @product_category_id
      body = JSON.parse(response.body)
      expect(body["products"].count).to eq(25)
    end

    it "should return 50 records max" do
      get :index, category_id: @product_category_id, page: 1, per_page: 55
      body = JSON.parse(response.body)
      expect(body["products"].count).to eq(50)
    end

    it "should return current page" do
      get :index, category_id: @product_category_id, page: 2, per_page: 20
      body = JSON.parse(response.body)
      expect(body["meta"]["current_page"]).to eq(2)
    end

    it "should return page count" do
      get :index, category_id: @product_category_id, page: 2, per_page: 20
      body = JSON.parse(response.body)
      expect(body["meta"]["page_count"]).to eq(3)
    end

    it "should return record count" do
      get :index, category_id: @product_category_id, page: 2, per_page: 20
      body = JSON.parse(response.body)
      expect(body["meta"]["record_count"]).to eq(55)
    end

    it "should be searchable" do
      search_term = @product.name[0..2]
      get :index, query: search_term
      body = JSON.parse(response.body)["products"]
      expect(body).not_to be_empty
    end
  end

  describe "GET #autocomplete" do
    before do
      category = FactoryGirl.create(:category)
      @products = FactoryGirl.create_list(:product, 20, category_id: category.id)
      @product = @products.sample
      @product_category_id = @product.category.id
      @products.each { |product| product.reindex }
      Product.searchkick_index.refresh
    end

    it "should return results" do
      search_term = @product.name[0..2]
      get :autocomplete, query: search_term
      body = JSON.parse(response.body)["products"]
      puts JSON.parse(response.body)
      expect(body).not_to be_empty
    end
  end

  describe "GET #show" do
    before(:each)do
      @product = FactoryGirl.create(:product_with_feedback)
      get :show, id: @product.id, category_id: category.id
    end

    it { should respond_with 200}

    it "requires a valid product id", skip_before: true do
      get :show, id: 3245, category_id: category.id
      should respond_with 404
    end

    it "should contain 5 feedbacks" do
      expect(@product.feedbacks.count).to eq(5)
    end
  end

  describe "POST #create" do
    it "should not be accessible" do
      should_not route(:post, '/products').to(action: 'create')
    end
  end

  describe "PUT #update" do
    it "should not be accessible" do
      should_not route(:put, '/products/1').to(action: 'update', id: 1)
    end
  end

  describe "DELETE #destroy" do
    it "should not be accessible" do
      should_not route(:delete, '/products/1').to(action: 'destroy', id: 1)
    end
  end
end
