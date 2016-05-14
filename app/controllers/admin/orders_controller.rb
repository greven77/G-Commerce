class Admin::OrdersController < Admin::BaseController
  include Pagination

  before_filter :authenticate_user_from_token!
  before_action :set_order, except: [:index, :create]

  def index
    #orders = @current_user.orders #uncomment to use in client api
    orders = Order #comment it in client api
    paginated_orders = paginate(orders, params)
    @orders = paginated_orders[:collection]

    if @orders
      render json: {orders: @orders, meta: paginated_orders[:meta]}
    else
      render status: :not_found,
        json: {
          error: "Orders not found"
        }
    end
  end

#admins can't create orders
#  def create
#    order = @current_user.orders.build
#    order.build_placements(order_params[:product_ids_and_quantities])

#    if @order.save
#      render status: :created,
#             json: @order
#    else
#      render status: :unprocessable_entity,
#             json: @order.errors.as_json
#   end
# end

  def update
#    @order.build_placements(order_params[:product_ids_and_quantities])
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

  def order_params
    params.require(:order)
      .permit(:user_id,
              :order_status_id, #admins can change order status
              :total,
              :page,
              :per_page,
              product_ids_and_quantities: [])
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
