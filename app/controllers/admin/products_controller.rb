class Admin::ProductsController < Admin::BaseController
  before_filter :authenticate_user_from_token!
  before_action :set_product, except: [:index, :create]

  def index
    @products = Product.all

    if @products
      render json: @products
    else
      render status: :not_found,
        json: {
          error: "Products not found"
        }
    end
  end

  def create
    #@product = Product.new(product_params)
    @product = Product.new(convert_data_uri_to_upload(product_params))
    if @product.save
      render status: :created,
             json: @product
    else
      render status: :unprocessable_entity,
             json: @product.errors.as_json
    end
  end

  def update
    if @product.update(convert_data_uri_to_upload(product_params))
      render status: :ok,
             json: @product
    else
      render status: :unprocessable_entity,
             json: @product.errors.as_json
    end
  end

  def destroy
    @product.destroy
    head 204
  end

  def show
    render status: :ok, json: @product if @product
  end

  private

  def product_params
    params.require(:product)
      .permit(:name, :product_code, :description, :price,
              :image,
              :image_url,
              category_attributes: [:id])
  end

  def set_product
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render status: :not_found,
           json: {
             error: "Product #{params[:id]} not found"
           }
  end
end
