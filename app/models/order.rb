class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :order_status

  has_many :placements
  has_many :products, through: :placements

  validates :total, presence: true,
            numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, presence: true

  before_create :assign_default_status

  private

  def assign_default_status
    self.order_status ||= OrderStatus.default
  end
end
