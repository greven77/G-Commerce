class Admin::BaseController < ApplicationController

  def authenticate_user_from_token!
    if authenticate_user.admin?
      super
    else
      return permission_denied
    end
  end
end
