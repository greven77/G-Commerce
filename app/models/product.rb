class Product < ActiveRecord::Base
  validates_presence_of :name, :price
  has_many :feedbacks, dependent: :destroy
  belongs_to :category
  has_many :placements, dependent: :destroy
  has_many :orders, through: :placements, dependent: :destroy
  mount_uploader :image, ProductImageUploader
  max_paginates_per 50
  attr_accessor :image_url

  searchkick match: :word_start, searchable: [:name, :description, :category]

  scope :by_category, lambda { |category_id|
    if category_id.present?
      where(category_id: category_id)
    end
  }

  after_commit :reindex_category

  def reindex_category
    category.reindex
  end

  def search_data
    {
      name: name,
      description: description,
      category: category.name
    }
  end

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
