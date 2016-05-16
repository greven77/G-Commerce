class FeedbackSerializer < ActiveModel::Serializer
  attributes :id, :comment, :rating, :product_id, :customer_id
  self.root = false
end
