class Admin::Products < Admin::BaseController
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
    @product = Product.new(product_params)

    if @product.save
      render status: :created,
             json: @product
    else
      render status: :unprocessable_entity,
             json: @product.errors.as_json
    end
  end

  def update
    if @product.update(trip_params)
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
    if @product
      render status: :ok,
             json: @product
    else
      render status: :not_found,
             json: {
               error: "Product #{params[:id]} not found"
             }
    end
  end

  private

  def product_params
    params.require(:product)
      .permit(:name, :product_code, :description, :price,
              category_attributes: [:id])
  end

  def set_product
  end
end
