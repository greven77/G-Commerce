class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.text :comment
      t.integer :rating
      t.references :product, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
