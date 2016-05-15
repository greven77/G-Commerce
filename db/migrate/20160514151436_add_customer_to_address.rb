class AddCustomerToAddress < ActiveRecord::Migration
  def change
    add_reference :addresses, :customer, index: true, foreign_key: true
  end
end
