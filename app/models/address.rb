class Address < ActiveRecord::Base
  belongs_to :customer
  belongs_to :country

  validates :street, :post_code, :city, :country, presence: true
end
