class Category < ActiveRecord::Base
  extend FriendlyId

  has_ancestry
  has_many :products, dependent: :nullify
  validates :name, presence: true
  friendly_id :name, use: :slugged
  attr_accessor :subcategories

  searchkick match: :word_start, searchable: [:name]

  def subcategories
    descendants.map { |category| CategorySerializer.new(category) }
  end

  def add_subcategories(subcategories)
    subcategories = JSON.parse(subcategories) unless subcategories.kind_of?(Array)
    subcategories.each do |subcategory|
      temp_cat = Category.create(name: subcategory["name"], parent: self)
      if subcategory["subcategories"].present?
        temp_cat.add_subcategories(subcategory["subcategories"])
      end
    end
  end
end
