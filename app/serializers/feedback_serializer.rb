class FeedbackSerializer < ActiveModel::Serializer
  attributes :id, :comment, :rating
  belongs_to :product_id
  belongs_to :user_id
end
