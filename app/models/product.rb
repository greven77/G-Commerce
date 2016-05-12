class Product < ActiveRecord::Base
  validates_presence_of :name, :price
  has_many :feedbacks, dependent: :destroy
  belongs_to :category
  has_many :placements
  has_many :orders, through: :placements
  mount_uploader :image, ProductImageUploader
  max_paginates_per 50
  attr_accessor :image_url

  scope :by_category, lambda { |category_id|
    if category_id.present?
      where(category_id: category_id)
    end
  }

  def rating
    rating_sum = self.feedbacks.inject(0) { |sum, n| sum + n.rating }
    feedback_count =  self.feedbacks.count.to_f
    round_dot_five(rating_sum / feedback_count)
  end

  def image_url
    self.image.url || ""
  end

  private

  def round_dot_five(num)
    (num*2).round / 2.0
  end
end
