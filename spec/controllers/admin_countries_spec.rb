require 'rails_helper'

RSpec.describe Admin::CountriesController, type: :controller do
  let!(:admin) { FactoryGirl.create(:user, :admin) }
  let!(:customer) { FactoryGirl.create(:user, :customer) }
  let!(:not_logged) { FactoryGirl.create(:user, :tokenless)}

  context "admin users" do
    describe "GET #index" do
      before do
        @countries = FactoryGirl.create_list(:country, 55)
      end

      it "should return 25 records only if no page or per page is specified" do
        get :index, auth_user_id: admin.id, auth_token: admin.authentication_token
        body = JSON.parse(response.body)
        expect(body["countries"].count).to eq(25)
      end

      it "should return 50 records max" do
        get :index, auth_user_id: admin.id, auth_token: admin.authentication_token,
            page: 1, per_page: 55
        body = JSON.parse(response.body)
        expect(body["countries"].count).to eq(50)
      end

      it "should return current page" do
        get :index, auth_user_id: admin.id, auth_token: admin.authentication_token,
            page: 2, per_page: 20
        body = JSON.parse(response.body)
        expect(body["meta"]["current_page"]).to eq(2)
      end

      it "should return page count" do
        get :index, auth_user_id: admin.id, auth_token: admin.authentication_token,
            page: 2, per_page: 20
        body = JSON.parse(response.body)
        expect(body["meta"]["page_count"]).to eq(3)
      end

      it "should return record count" do
        get :index, auth_user_id: admin.id, auth_token: admin.authentication_token,
            page: 2, per_page: 20
        body = JSON.parse(response.body)
        expect(body["meta"]["record_count"]).to eq(55)
      end
    end

    describe "GET #show" do
      before(:each) do
        @country = FactoryGirl.create(:country)
        get :show, id: @country.id, auth_user_id: admin.id,
            auth_token: admin.authentication_token
      end

      it { should respond_with 200}

      it "requires a valid country id", skip_before: true do
        get :show, id: 3245, auth_user_id: admin.id,
            auth_token: admin.authentication_token
        should respond_with 404
      end
    end

    describe "POST #create" do
      before do
        @country = FactoryGirl.build(:country).as_json
        post :create, country: @country,
             auth_user_id: admin.id,
             auth_token: admin.authentication_token
        @body = JSON.parse(response.body)
      end
      it { should respond_with 201}

      it "Shouldn't allow creation" do
        @country["name"] = nil
        post :create, country: @country,
             auth_user_id: admin.id,
             auth_token: admin.authentication_token
        should respond_with 422
      end
    end

    describe "DELETE #destroy" do
      before(:each) do
        @country = FactoryGirl.create(:country)
        delete :destroy, id: @country.id, auth_user_id: admin.id,
               auth_token: admin.authentication_token
      end

      it { should respond_with 204}

      it "deleted country should not be present" do
        expect {
             Country.find(@country.id)
           }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    describe "PUT #update" do

      before do
        @country = FactoryGirl.create(:country)
        @old_country = @country.clone.as_json
        @country = @country.as_json.except("image")
        @country["name"] = "new name"

        put :update, country: @country,
            id: @country["id"],
            auth_user_id: admin.id,
            auth_token: admin.authentication_token
        @body = JSON.parse(response.body)
      end

      it { should respond_with 200 }

      it "should not contain the old values" do
        @old_country = @old_country.except("created_at", "updated_at")
        @body = @body.except("created_at", "updated_at")
        expect(@body).to_not eq(@old_country)
      end
    end
  end

  context "customer users" do
    before(:each) do
      @country = FactoryGirl.create(:country)
    end

    describe "GET #show" do
      it "should not be authorized to access" do
        get :show, id: @country.id, auth_user_id: customer.id,
            auth_token: customer.authentication_token
        expect(response.status).to eq(401)
      end
    end

    describe "POST #create" do
      it "should not be authorized to access" do
        post :create, country: @country, auth_user_id: customer.id,
             auth_token: customer.authentication_token
        expect(response.status).to eq(401)
      end
    end

    describe "PUT #update" do
      it "should not be authorized to access" do
        @country.name = "new name"
        @country.save
        put :update, country: @country.as_json,
            id: @country.id,
            auth_user_id: customer.id,
            auth_token: customer.authentication_token
        expect(response.status).to eq(401)
      end
    end

    describe "DELETE #destroy" do
      it "should not be authorized to access" do
        delete :destroy, id: @country.id, auth_user_id: customer.id,
               auth_token: customer.authentication_token
        expect(response.status).to eq(401)
      end
    end
  end

  context "not logged users" do
    before(:each) do
      @country = FactoryGirl.create(:country)
    end

    describe "GET #show" do
      it "should not be authorized to access" do
        get :show, id: @country.id, auth_user_id: not_logged.id,
            auth_token: nil
        expect(response.status).to eq(401)
      end
    end

    describe "POST #create" do
      it "should not be authorized to access" do
        post :create, country: @country, auth_user_id: not_logged.id,
             auth_token: nil
        expect(response.status).to eq(401)
      end
    end

    describe "PUT #update" do
      it "should not be authorized to access" do
        @country.name = "new name"
        @country.save
        put :update, country: @country.as_json,
            id: @country.id,
            auth_user_id: not_logged.id,
            auth_token: nil
        expect(response.status).to eq(401)
      end
    end

    describe "DELETE #destroy" do
      it "should not be authorized to access" do
        delete :destroy, id: @country.id, auth_user_id: not_logged.id,
               auth_token: nil
        expect(response.status).to eq(401)
      end
    end
  end
end
