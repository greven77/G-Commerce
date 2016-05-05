class Category < ActiveRecord::Base
  belongs_to :parent, class_name: "Category"
  has_many :children, class_name: "Category", foreign_key: "parent_id"
  has_many :products

  def parent_name
    parent.try(:name)
  end

  def has_parent?
    parent.present?
  end

  def has_children?
    children.exists?
  end
end
