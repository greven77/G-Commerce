class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :product_code,:price, :description, :category_id, :image_url
  has_many :feedbacks
  self.root = false
end
