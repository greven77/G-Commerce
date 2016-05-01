class Admin::Products < Admin::BaseController
  def index
  end

  def create
  end

  def update
  end

  def destroy
  end

  def show
  end

  private

  def product_params
    params.require(:product)
      .permit(:name, :product_code, :description, :price,
              category_attributes: [:id])
  end
end
