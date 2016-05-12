class FeedbackSerializer < ActiveModel::Serializer
  attributes :id, :comment, :rating, :product_id
  belongs_to :product_id
  belongs_to :user_id
  self.root = false
end
