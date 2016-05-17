class ProductsController < ApplicationController
  include Pagination

  before_action :set_product, except: [:index]

  def index
    products = Product.by_category(params[:category_id])
    paginated_products = paginate(products, params)
    @products = paginated_products[:collection]

    if @products
      render json: {products: @products, meta: paginated_products[:meta]}
    else
      render status: :not_found,
        json: {
          error: "Products not found"
        }
    end
  end

  def show
    render status: :ok, json: @product if @product
  end

  private

  def set_product
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render status: :not_found,
           json: {
             error: "Product #{params[:id]} not found"
           }
  end
end
