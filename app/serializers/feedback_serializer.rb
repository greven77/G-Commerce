class FeedbackSerializer < ActiveModel::Serializer
  attributes :id, :comment, :rating
  belongs_to :product_id
  belongs_to :user_id

  def page_count
  end

  def current_page
  end

  def record_count
  end
end
