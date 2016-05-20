class CartsController < ApplicationController
  before_filter :authenticate_user_from_token!
  before_action :set_cart

  def show
    render status: :ok, json: @cart.products, root: false
  end

  def increase_product_quantity
    if @cart.increase(params[:product_id])
      render status: :ok,
             json: @cart.products
    else
      render status: :unprocessable_entity
    end
  end

  def decrease_product_quantity
    if @cart.decrease(params[:product_id])
      render status: :ok,
             json: @cart.products
    else
      render status: :unprocessable_entity
    end
  end

  def set_product_quantity
    if @cart.set_quantity(params[:product_id]. params[:quantity])
      render status: :ok,
             json: @cart.products
    else
      render status: :unprocessable_entity
    end
  end

  def remove_product
    if @cart.remove_product(params[:product_id])
      render status: :ok,
             json: @cart.products
    else
      render status: :unprocessable_entity
    end
  end

  def destroy
    @cart.destroy
    head 204
  end

  private

  def set_cart
    @cart = Cart.new(@current_user.id)
  rescue ArgumentError
    render status: :not_found,
           json: { error: "Cart not found" }
  end
end
