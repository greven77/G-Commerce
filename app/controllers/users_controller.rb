class UsersController < ApplicationController
  include Pagination
  before_filter :authenticate_user_from_token!, :only => [:index]

  def index
    return permission_denied unless (params[:id].to_s == @current_user.id.to_s) ||
                                    (params[:email].to_s == @current_user.email.to_s) ||
                                    @current_user.admin?

    if params[:query].present? && @current_user.admin?
      @users = User.search(params[:query], {
        page: params[:page], per_page: params[:per_page],
        fields: [:email, :role_name], misspellings: { below: 3 },
        order: {_score: :desc, created_at: :desc}
      })
      meta = {}
    elsif @current_user.admin?
      paginated_users = paginate(User, params)
      @users = paginated_users[:collection]
      meta = paginated_users[:meta]
    else
      @users = User.where(params.permit(:id, :email))
      meta = {}
    end

    if @users
      render status: :ok,
             json: @users.as_json, meta: meta
    else
      render status: :not_found,
             json: {
               error: "Users not found"
             }
    end
  end

  def autocomplete
    permission_denied unless @current_user.admin?
    users = User.search(params[:query], {
      fields: ["email^2", "role_name"],
      limit: 10,
      misspellings: { below: 3 },
      load: false,
      order: {_score: :desc, created_at: :desc}
    }).map { |user| { id: user.email,
                      text: user.autocomplete_item } }
    render json: users, status: :ok
  end
end
