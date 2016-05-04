class Product < ActiveRecord::Base
  validates_presence_of :name, :price
  has_many :feedbacks
end
