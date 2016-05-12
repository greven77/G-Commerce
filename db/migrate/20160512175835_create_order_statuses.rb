class CreateOrderStatuses < ActiveRecord::Migration
  def change
    create_table :order_statuses do |t|
      t.string :description

      t.timestamps null: false
    end
  end
end
