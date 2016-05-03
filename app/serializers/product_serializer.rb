class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :product_code, :description
end
