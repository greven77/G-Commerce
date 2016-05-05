class Product < ActiveRecord::Base
  validates_presence_of :name, :price
  has_many :feedbacks
  belongs_to :category

  def rating
    rating_sum = self.feedbacks.inject(0) { |sum, n| sum + n.rating }
    feedback_count =  self.feedbacks.count.to_f
    round_dot_five(rating_sum / feedback_count)
  end

  private

  def round_dot_five(num)
    (num*2).round / 2.0
  end
end
