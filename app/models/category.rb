class Category < ActiveRecord::Base
  has_ancestry
  has_many :products
  validates :name, presence: true
  
#  def subcategories
#    self[:subcategories]
#  end

#  def subcategories=(val)
#    self[:subcategories] = val
#  end

  def subcategories
    descendants.map { |category| CategorySerializer.new(category) }
  end
end
