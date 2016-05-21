class Admin::CustomersController < Admin::BaseController
  include Pagination

  before_filter :authenticate_user_from_token!
  before_action :set_customer, except: [:index, :create, :autocomplete]

  def index
    if params[:query].present?
      @customers = Customer.search(params[:query], {
        page: params[:page], per_page: params[:per_page],
        fields: [:name, :email], misspellings: {below: 5},
        order: {_score: :desc, created_at: :desc}
      })
      meta = {}
    else
      paginated_customers = paginate(Customer, params)
      meta = paginated_customers[:meta]
      @customers = paginated_customers[:collection]
    end

    if @customers
      render json: @customers, meta: meta
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

  def autocomplete
    customers = Customer.search(params[:query], {
      fields: ["name", "email^2"],
      limit: 10,
      misspellings: {below: 3},
      load: false,
      order: {_score: :desc, created_at: :desc}
    }).map { |customer| { id: customer.email,
                          text: customer.autocomplete_item } }
    render json: customers, status: :ok
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
