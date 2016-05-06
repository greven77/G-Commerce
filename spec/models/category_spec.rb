require 'rails_helper'

RSpec.describe Category, type: :model do
  let!(:category) { FactoryGirl.create(:category) }
  let!(:subcategory_a) { FactoryGirl.create(:category, parent_id: category.id) }
  let!(:subcategory_b) { FactoryGirl.create(:category, parent_id: category.id) }
  before do
    4.times { subcategory_a.products.create(FactoryGirl.attributes_for(:product)) }
    6.times { subcategory_b.products.create(FactoryGirl.attributes_for(:product) )}
  end

  it { should have_many :products }
  it { should have_many :children }
  it { should belong_to :parent }
  it { should validate_presence_of :name }

  describe "category" do
    it "should have children" do
      expect(category.has_children?).to be true
    end

    it "should have two subcategories" do
      expect(category.children.count).to eq(2)
    end
  end

  describe "subcategories" do
    it "should add the correct amount of products to subcategories" do
      expect(subcategory_a.products.count).to eq(4)
      expect(subcategory_b.products.count).to eq(6)
    end

    it "should have a parent" do
      expect(subcategory_a.has_parent?).to be true
    end

    it "should have a parent name" do
      expect(subcategory_a.parent_name).not_to be_empty
    end
  end
end
