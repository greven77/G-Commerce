class Order < ActiveRecord::Base
  belongs_to :customer
  belongs_to :order_status

  has_many :placements, dependent: :destroy
  has_many :products, through: :placements, dependent: :destroy

  before_create :assign_default_status
  before_validation :set_total!

  attr_accessor :product_ids_and_quantities

  max_paginates_per 50

  validates :customer_id, presence: true

  accepts_nested_attributes_for :placements,
                                allow_destroy: true,
                                reject_if: :all_blank

  searchkick match: :word_start, searchable: [:customer, :order_status]
  after_commit :reindex_customer
  after_commit :reindex_order_status

  def reindex_customer
    customer.reindex
  end

  def reindex_order_status
    order_status.reindex
  end

  def search_data
    {
      customer: customer.name,
      order_status: order_status.description,
      created_at: created_at
    }
  end

  def autocomplete_item
    "#{customer.name}:#{created_at.strftime("%d-%m-%Y")}:#{id}"
  end

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

  def editable_by_customer?
    self.order_status.editable_by_customer
  end

  private

  def assign_default_status
    self.order_status ||= OrderStatus.default
  end
end
