class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :products, :subcategories
end
