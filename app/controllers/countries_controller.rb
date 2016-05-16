class CountriesController < ApplicationController
  def index
    render status: :ok, json: Country.all
  end
end
