class Admin::CategoriesController < Admin::BaseController
  before_filter :authenticate_user_from_token!
  before_action :set_category, except: [:index, :create]

  def index
    @categories = Category.all

    if @categories
      render json: @categories
    else
      render status: :not_found,
        json: {
          error: "Categories not found"
        }
    end
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      render status: :created,
             json: @category
    else
      render status: :unprocessable_entity,
             json: @category.errors.as_json
    end
  end

  def update
    if @category.update(category_params)
      render status: :ok,
             json: @category
    else
      render status: :unprocessable_entity,
             json: @category.errors.as_json
    end
  end

  def destroy
    @category.destroy
    head 204
  end

  def show
    render status: :ok, json: @category if @category
  end

  private

  def category_params
    params.require(:category)
      .permit(:name, :category_code, :description, :price,
              category_attributes: [:id])
  end

  def set_category
    @category = Category.find(params[:name])
  rescue ActiveRecord::RecordNotFound
    render status: :not_found,
           json: {
             error: "Category #{params[:name]} not found"
           }
  end
end
