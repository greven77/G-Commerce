class Cart

  attr_accessor :products, :cart_id, :user_id

  def initialize(user_id)
    if !(user_id > 0 && user_id.is_a?(Integer))
      raise ArgumentError.new("user_id must be either an integer and greater than zero")
    end

    @user_id = user_id
    @products = Cart.get(user_id)
    @cart_id = "cart:#{user_id}"
  end

  def self.get(user_id)
    Cart.create(user_id) unless $redis.exists("cart:#{user_id}")
    JSON.parse($redis.get("cart:#{user_id}"))
  end

  def self.create(user_id)
    return false if unless $redis.exists("cart:#{user_id}")
    $redis.set("cart:#{user_id}", [].to_json)
    $redis.expire("cart:#{user_id}", 60 * 60 * 72) #cart expires in 3 days
  end

  def increase(product_id)
    product_exists = !find_or_create_product(product_id).is_a?(Array)

    if product_exists
      update_cart(product_id) do |item|
        item["quantity"] += 1
      end
    end
  end

  def decrease(product_id)
    product_exists = find_or_create_product(product_id).is_a?(Array)

    if product_exists
      update_cart(product_id) do |item|
        item["quantity"] -= 1
      end
    end
  end

  def set_quantity(product_id, quantity)
    find_or_create_product(product_id)
    update_cart(product_id) do |item|
      item["quantity"] = quantity
    end
  end

  def remove_product(product_id)
    updated_cart = @products.select { |item| item["product_id"] != product_id }
    redis.set(@cart_id, updated_cart.to_json)
    refresh_products
  end

  def destroy
    return false unless $redis.exists(@cart_id)
    $redis.del(@cart_id)
  end

  private

  def update_cart(product_id)
    cart = @products
    updated_cart = cart.map do |item|
      yield(item) if item["product_id"] == product_id
      item unless item["quantity"] <= 0
    end
    redis.set(@cart_id, updated_cart.compact.to_json)
    refresh_products
  end

  def add_new_product(product_id)
    cart = @products
    cart << { "product_id": product_id, "quantity": 1}.as_json
    redis.set(@cart_id, cart.to_json)
    refresh_products
  end

  def find_or_create_product(product_id)
    product = @products.select { |item| item["product_id"] == product_id }.first
    if !product
      add_new_product(product_id)
    else
      product
    end
  end

  def refresh_products
    @products = Cart.get(@user_id)
  end
end
