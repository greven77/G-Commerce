class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :subcategories
  has_many :products
  self.root = false
end
