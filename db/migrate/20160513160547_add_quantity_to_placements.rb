class AddQuantityToPlacements < ActiveRecord::Migration
  def change
    add_column :placements, :quantity, :integer
  end
end
