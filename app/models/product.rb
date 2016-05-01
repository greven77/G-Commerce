class Product < ActiveRecord::Base
  belongs_to :attachment
  belongs_to :category
end
