class CategoriesController < ApplicationController
  before_action :set_category, except: [:index, :autocomplete]

  def index
    if params[:query].present?
      @categories = Category.search(params[:query])
    else
      @categories = Category.all
    end

    if @categories
      render json: @categories
    else
      render status: :not_found,
        json: {
          error: "Categories not found"
        }
    end
  end

  def show
    render status: :ok, json: @category if @category
  end

  def autocomplete
    @categories = Category.search(params[:query]).map(&:name)
    render json: @categories, status: :ok
  end

  private

  def set_category
    @category = Category.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render status: :not_found,
           json: {
             error: "Category #{params[:id]} not found"
           }
  end
end
