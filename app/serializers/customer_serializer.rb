class CustomerSerializer < ActiveModel::Serializer
  attributes :id, :name, :phone, :billing_address, :shipping_address, :payment_method
  has_one :billing_address
  has_one :shipping_address
  has_one :payment_method
  has_many :feedbacks
  has_many :orders
  self.root = false
end
