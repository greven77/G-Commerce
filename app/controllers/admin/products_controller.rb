class Admin::ProductsController < Admin::BaseController
  include Pagination

  before_filter :authenticate_user_from_token!
  before_action :set_product, except: [:index, :create, :autocomplete]

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

  def autocomplete
    products = Product.search(params[:query], {
      fields: ["name^10", "category^5", "description"],
      limit: 10,
      misspellings: {below: 5},
      load: false
    }).map(&:name)
    render json: products, status: :ok
  end

  private

  def product_params
    params.require(:product)
      .permit(:name, :product_code, :description, :price,
              :image,
              :image_url,
              :page,
              :per_page,
              :category_id)
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
