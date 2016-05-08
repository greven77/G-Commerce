class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :product_code,:price, :description, :category_id
  has_many :feedbacks
  self.root = false
end
