class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.references :user, index: true, foreign_key: true
      t.string :name
      t.string :phone
      t.timestamps null: false
    end
  end
end
