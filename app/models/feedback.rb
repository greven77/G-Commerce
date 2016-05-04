class Feedback < ActiveRecord::Base
  belongs_to :product
  belongs_to :user
  validates :comment, :rating, :product_id, :user_id, presence: true
end
