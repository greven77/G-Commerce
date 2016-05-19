class OrdersController < ApplicationController
  include Pagination

  before_filter :authenticate_user_from_token!
  before_action :set_order, except: [:index, :create]
  before_filter :ensure_own_user
  before_action :editing_allowed?, only: [:update, :destroy]

  def index
    orders = @current_user.customer.orders
    paginated_orders = paginate(orders, params)
    @orders = paginated_orders[:collection]

    if @orders
      render json: @orders, meta: paginated_orders[:meta]
    else
      render status: :not_found,
        json: {
          error: "Orders not found"
        }
    end
  end

  def create
    @order = @current_user.customer.orders.build(order_params)

    if @order.save
      render status: :created,
             json: @order
    else
      render status: :unprocessable_entity,
             json: @order.errors.as_json
    end
  end

  def update
    if @order.update(order_params)
      render status: :ok,
             json: @order
    else
      render status: :unprocessable_entity,
             json: @order.errors.as_json
    end
  end

  def destroy
    @order.destroy
    head 204
  end

  def show
    render status: :ok, json: @order if @order
  end

  private

  def ensure_own_user
    customer_user_id =  Customer.find(params["customer_id"]).user.id
    permission_denied unless customer_user_id == @current_user.id
  end

  def editing_allowed?
    permission_denied unless @order.editable_by_customer?
  end

  def order_params
    params.require(:order)
      .permit(:customer_id,
              :order_status_id, #admins can change order status
              :total,
              :page,
              :per_page,
              product_ids_and_quantities: [],
              placements_attributes: [:id, :order_id, :product_id, :quantity,
                                      :_destroy])
  end

  def set_order
    @order = Order.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render status: :not_found,
           json: {
             error: "Order #{params[:id]} not found"
           }
  end
end
