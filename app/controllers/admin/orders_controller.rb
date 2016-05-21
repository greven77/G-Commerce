class Admin::OrdersController < Admin::BaseController
  include Pagination

  before_filter :authenticate_user_from_token!
  before_action :set_order, except: [:index, :create, :autocomplete]

  def index
    if params[:query].present?
      @orders = Order.search(params[:query],{
        page: params[:page], per_page: params[:per_page],
        fields: [:customer, :order_status], misspellings: {below: 5},
        order: {_score: :desc, created_at: :desc}
      })
      meta = {}
    else
      orders = Order
      paginated_orders = paginate(orders, params)
      @orders = paginated_orders[:collection]
      meta = paginated_orders[:meta]
    end

    if @orders
      render json: {orders: @orders, meta: meta}
    else
      render status: :not_found,
        json: {
          error: "Orders not found"
        }
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

  def autocomplete
    orders = Order.search(params[:query], {
      fields: ["customer^2", "order_status"],
      limit: 10,
      misspellings: { below: 5 },
      load: false,
      order: { _score: :desc, created_at: :desc }
    }).map { |order| { id: order.customer,
                       text: order.autocomplete_item } }
    render json: orders, status: :ok
  end

  private

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
