class ProductsController < ApplicationController
  include Pagination

  before_action :set_product, except: [:index, :autocomplete]

  def index
    if params[:query].present?
      @products = Product.search(params[:query], {
        page: params[:page], per_page: params[:per_page],
        fields: ["name^10", "category^5", "description"],
        misspellings: {below: 5}
      })
      meta = {}
    else
      products = Product.by_category(params[:category_id])
      paginated_products = paginate(products, params)
      @products = paginated_products[:collection]
      meta = paginated_products[:meta]
    end

    if @products
      render json: {products: @products, meta: meta}
    else
      render status: :not_found,
        json: {
          error: "Products not found"
        }
    end
  end

  def autocomplete
    products = Product.search(params[:query], {
      fields: ["name^10", "category^5", "description"],
      limit: 10,
      misspellings: {below: 5},
      load: false
                              }).map(&:name)
    render json: products, status: :ok
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
