class Feedback < ActiveRecord::Base
  belongs_to :product
  belongs_to :user
  validates :comment, :rating, :product_id, :user_id, presence: true
  validates :rating,
            :inclusion => { in: 0..5,
                            :message => "Must be rated between 0 and 5 stars"}
  max_paginates_per 100
end
