class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :order_status

  has_many :placements, dependent: :destroy
  has_many :products, through: :placements, dependent: :destroy

  before_create :assign_default_status
  before_validation :set_total!

  max_paginates_per 50

  validates :user_id, presence: true

  def set_total!
    self.total = 0
    placements.each do |placement|
      self.total += placement.product.price * placement.quantity
    end
  end

  def build_placements(product_ids_and_quantities)
    product_ids_and_quantities.each do |product_id_and_quantity|
      id, quantity = product_id_and_quantity

      self.placements.build(product_id: id, quantity: quantity)
    end
  end

  private

  def assign_default_status
    self.order_status ||= OrderStatus.default
  end
end
