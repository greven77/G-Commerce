class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :product_code,:price, :description, :category_id,
             :image_url
  has_many :feedbacks
  self.root = false

  def feedbacks
    # limits embed feedbacks to kaminari's default per page
    object.feedbacks.limit(object.feedbacks.default_per_page)
  end
end
