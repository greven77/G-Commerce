class Admin::CountriesController < Admin::BaseController
  include Pagination
  before_filter :authenticate_user_from_token!, except: [:index]
  before_action :set_country, except: [:index, :create]

  def index
    countries = Country
    paginated_countries = paginate(countries, params)
    @countries = paginated_countries[:collection]
    if @countries
      render json: {countries: @countries, meta: paginated_countries[:meta] }
    else
      render status: :not_found,
        json: {
          error: "Countries not found"
        }
    end
  end

  def create
    @country = Country.new(country_params)

    if @country.save
      render status: :created,
             json: @country
    else
      render status: :unprocessable_entity,
             json: @country.errors.as_json
    end
  end

  def update
    if @country.update(country_params)
      render status: :ok,
             json: @country
    else
      render status: :unprocessable_entity,
             json: @country.errors.as_json
    end
  end


  def destroy
    @country.destroy
    head 204
  end

  def show
    render status: :ok, json: @country if @country
  end

  private

  def country_params
    params.require(:country)
      .permit(:id, :name)
  end

  def set_country
    @country = Country.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render status: :not_found,
           json: {
             error: "Country #{params[:id]} not found"
           }
  end
end
