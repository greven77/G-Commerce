class OrderProductSerializer < ActiveModel::Serializer
  attributes :product_id, :name, :price
  self.root = false

  def product_id
    object.id
  end
end
