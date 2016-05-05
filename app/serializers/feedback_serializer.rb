class FeedbackSerializer < ActiveModel::Serializer
  attributes :id, :comment, :rating, :product_id, :user_id
end
