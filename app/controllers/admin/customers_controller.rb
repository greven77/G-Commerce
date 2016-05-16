class Admin::CustomersController < Admin::BaseController
  include Pagination

  before_filter :authenticate_user_from_token!
  before_action :set_customer, except: [:index, :create]

  def index
    paginated_customers = paginate(Customer, params)
    @customers = paginated_customers[:collection]

    if @customers
      render json: @customers, meta: paginated_customers[:meta]
    else
      render status: :not_found,
        json: {
          error: "Customers not found"
        }
    end
  end

  def create
    @customer = Customer.new(customer_params)

    if @customer.save
      render status: :created,
             json: @customer
    else
      render status: :unprocessable_entity,
             json: @customer.errors.as_json
    end
  end

  def update
    if @customer.update(customer_params)
      render status: :ok,
             json: @customer
    else
      render status: :unprocessable_entity,
             json: @customer.errors.as_json
    end
  end

  def destroy
    @customer.destroy
    head 204
  end

  def show
    render status: :ok, json: @customer if @customer
  end

  private

  def customer_params
    #params[:customer][:subcustomers] ||= []
    params.require(:customer)
      .permit(:name, :phone, :user_id,
              billing_address_attributes: [:id, :street, :post_code, :city,
                                           :country_id, :customer_id],
              shipping_address_attributes: [:id, :street, :post_code, :city,
                                            :country_id, :customer_id],
              payment_method_attributes: [:id, :card_type, :card_number,
                                         :verification_code, :valid_until])
  end

  def set_customer
    @customer = Customer.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render status: :not_found,
           json: {
             error: "Customer #{params[:id]} not found"
           }
  end
end
