class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :subcategories, :parent_id
  has_many :products
  self.root = false

  def products
    # limits embed products to kaminari's default per page
    object.products.limit(object.products.default_per_page)
  end
end
