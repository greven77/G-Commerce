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
    #puts category_params
    @category = Category.new(category_params)
    # implement subcategories addition case params[:subcategories]
    if @category.save
      subcategories = category_params["subcategories"]
      @category.add_subcategories(subcategories) if subcategories
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
    #params[:category][:subcategories] ||= []
    params.require(:category)
      .permit(:name, subcategories: [:name, subcategories: []])
  end

  def set_category
    @category = Category.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render status: :not_found,
           json: {
             error: "Category #{params[:id]} not found"
           }
  end
end
