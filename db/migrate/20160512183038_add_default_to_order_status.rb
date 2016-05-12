class AddDefaultToOrderStatus < ActiveRecord::Migration
  def change
    add_column :order_statuses, :default, :boolean, default: false
  end
end
