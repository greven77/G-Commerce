class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :street
      t.string :post_code
      t.string :city

      t.timestamps null: false
    end
  end
end
