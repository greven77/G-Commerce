class Admin::FeedbacksController < Admin::BaseController
  include Pagination

  before_filter :authenticate_user_from_token!, except: [:index]
  before_action :set_feedback, except: [:index, :create]

  def index
    feedbacks = Feedback.where(product: params[:product_id])
    paginated_feedbacks = paginate(feedbacks, params)
    @feedbacks = paginated_feedbacks[:collection]

    if @feedbacks
      render json: {feedbacks: @feedbacks, meta: paginated_feedbacks[:meta]}
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
              :product_id, :customer_id,
              :page, :per_page)
  end

  def set_feedback
    @feedback = Feedback.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render status: :not_found,
           json: {
             error: "Feedback #{params[:id]} not found"
           }
  end
end
