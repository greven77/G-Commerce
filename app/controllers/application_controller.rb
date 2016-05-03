class ApplicationController < ActionController::API
#  protect_from_forgery with: :null_session

  private

  def authenticate_user
    user_id = params[:auth_user_id].presence
    @user ||=  user_id && User.find_by_id(user_id)
  end

  def authenticate_user_from_token!
    if authenticate_user && Devise.secure_compare(@user.authentication_token, params[:auth_token])
      @current_user = authenticate_user
    else
      return permission_denied
    end
  end

  def permission_denied
    render json: { error: "Unauthorized"}, status: 401
  end
end
