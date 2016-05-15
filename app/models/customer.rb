class Customer < ActiveRecord::Base
  belongs_to :user

  has_one :billing_address, :class_name => "Address"
  has_one :shipping_address, :class_name => "Address"

  has_one :payment_method, :class_name => "Payment"

  validates :name, :phone, :billing_address, :shipping_address, :payment_method,
            presence: true
end
