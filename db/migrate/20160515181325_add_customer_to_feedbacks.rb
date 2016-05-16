class AddCustomerToFeedbacks < ActiveRecord::Migration
  def change
    add_reference :feedbacks, :customer, index: true, foreign_key: true
  end
end
