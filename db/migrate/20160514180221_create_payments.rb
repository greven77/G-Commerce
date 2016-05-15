class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :type
      t.string :card_number
      t.string :valid_until
      t.integer :verification_code
      t.references :customer, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
