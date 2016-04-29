class UsersController < ApplicationController
  before_filter :authenticate_user_from_token!, :only => [:index]

  def index
    return permission_denied unless (params[:id].to_s == @current_user.id.to_s) ||
                                    (params[:email].to_s == @current_user.email.to_s)

    @users = User.where(params.permit(:id, :email))

    if @users
      render status: :ok,
             json: @users.as_json
    else
      render status: :not_found,
             json: {
               error: "Users not found"
             }
    end
  end
end
