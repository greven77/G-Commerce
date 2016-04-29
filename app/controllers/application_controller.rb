class ApplicationController < ActionController::API
  protect_from_forgery with: :null_session

  private

  def authenticate_user_from_token!
    user_id = params[:auth_user_id].presence
    user = user_id && User.find_by_id(user_id)

    if user && Devise.secure_compare(user.authentication_token, params[:auth_token])
      @current_user = user
    else
      return permission_denied
    end
  end

  def permission_denied
    render :file => "public/401.html", :status => :unauthorized, :layout => false
  end
end
