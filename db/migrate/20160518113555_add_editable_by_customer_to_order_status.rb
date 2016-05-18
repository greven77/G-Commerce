class AddEditableByCustomerToOrderStatus < ActiveRecord::Migration
  def change
    add_column :order_statuses, :editable_by_customer, :boolean
  end
end
