class FeedbacksController < ApplicationController
  before_filter :authenticate_user_from_token!, except: [:index]
  before_action :set_feedback, except: [:index, :create]
  before_action :ensure_deletion_by_author_or_admin, only: [:destroy]

  def index
    @feedbacks = Feedback.where(product_id: params[:product_id])

    if @feedbacks
      render json: @feedbacks
    else
      render status: :not_found,
        json: {
          error: "Feedbacks not found"
        }
    end
  end

  def create
    @feedback = Feedback.new(feedback_params)

    if @feedback.save
      render status: :created,
             json: @feedback
    else
      render status: :unprocessable_entity,
             json: @feedback.errors.as_json
    end
  end

  def destroy
    @feedback.destroy
    head 204
  end

  def show
    render status: :ok, json: @feedback if @feedback
  end

  private

  def feedback_params
    params.require(:feedback)
      .permit(:comment, :rating,
              :product_id, :user_id)
  end

  def set_feedback
    @feedback = Feedback.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render status: :not_found,
           json: {
             error: "Feedback #{params[:id]} not found"
           }
  end

  def ensure_deletion_by_author_or_admin
    user = User.find(params[:user_id])
    permission_denied unless params[:user_id] == @feedback.user_id || user.admin?
  end
end
