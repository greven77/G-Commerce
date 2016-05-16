class Feedback < ActiveRecord::Base
  belongs_to :product
  belongs_to :customer
  validates :comment, :rating, :product_id, :customer_id, presence: true
  validates :rating,
            :inclusion => { in: 0..5,
                            :message => "Must be rated between 0 and 5 stars"}
  max_paginates_per 50
end
