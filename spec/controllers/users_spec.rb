require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let!(:admin) { FactoryGirl.create(:user, :admin) }
  let!(:customer) { FactoryGirl.create(:user, :customer) }
  let!(:not_logged) { FactoryGirl.create(:user, :tokenless)}

  context "admin users" do
    describe "GET #index" do
      before do
        @users = FactoryGirl.create_list(:user, 52, :customer)
        @user = @users.sample
        User.reindex
        User.searchkick_index.refresh
      end

      it "should return 25 records only if no page or per page is specified" do
        get :index, auth_user_id: admin.id, auth_token: admin.authentication_token
        body = JSON.parse(response.body)
        expect(body["users"].count).to eq(25)
      end

      it "should return 50 records max" do
        get :index, auth_user_id: admin.id, auth_token: admin.authentication_token,
            page: 1, per_page: 55
        body = JSON.parse(response.body)
        expect(body["users"].count).to eq(50)
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

      it "should be searchable" do
        search_term = @user.email[0..2]
        get :index, query: search_term, auth_token: admin.authentication_token,
            auth_user_id: admin.id
        body = JSON.parse(response.body)["users"]
        expect(body).not_to be_empty
      end
    end

    describe "GET #autocomplete" do
      before do
        @users = FactoryGirl.create_list(:user, 15, :customer)
        @user = @users.sample
        User.reindex
        User.searchkick_index.refresh
      end

      it "should return results" do
        search_term = @user.email[0..2]
        get :autocomplete, query: search_term,
            auth_token: admin.authentication_token,
            auth_user_id: admin.id
        body = JSON.parse(response.body)["users"]
        expect(body).not_to be_empty
      end
    end

    describe "GET #show" do
      before do
        @user = FactoryGirl.create(:user)
        get :show, id: @user.id, auth_user_id: admin.id,
            auth_token: admin.authentication_token
      end

      it { should respond_with 200 }

      it "should have a role id" do
        body = JSON.parse(response.body)
        expect(body["user_role"]).to eq(@user.user_role)
      end
    end

    describe "POST #create" do
      before do
        user = FactoryGirl.build(:user)
        @user_json = user.as_json
        @user_json["password"] = user.password
        @user_json["password_confirmation"] = user.password_confirmation
        post :create, user: @user_json,
             auth_user_id: admin.id,
             auth_token: admin.authentication_token
        @body = JSON.parse(response.body)
      end

      it { should respond_with 201}

      it "should respond with a user" do
        correct_attributes = @body["id"].present? && @body["email"].present? &&
                             @body["user_role"].present?
        expect(correct_attributes).to eq(true)
      end
    end

    describe "DELETE #destroy" do
      before do
        @user = FactoryGirl.create(:user)
        delete :destroy, id: @user.id, auth_user_id: admin.id,
               auth_token: admin.authentication_token
      end

      it { should respond_with 204 }

      it "deleted user should not be present" do
        expect {
          User.find(@user.id)
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    describe "PUT #update" do
      before do
        @user = FactoryGirl.create(:user).as_json
        @user["email"] = "asdasdasd324@examp.com"

        put :update, id: @user["id"],
            user: @user.as_json,
            auth_user_id: admin.id,
            auth_token: admin.authentication_token
      end

      it { should respond_with 200 }

      it "should contain a new value" do
        body = JSON.parse(response.body)
        expect(body["email"]).to eq(@user["email"])
      end
    end
  end
end
