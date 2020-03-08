class CreatePerformances < ActiveRecord::Migration[6.0]
  def change
    create_table :performances do |t|
      t.string :user_id
      t.string :trade_id
      t.string :stock_code
      t.string :stock_name
      t.string :transaction_type
      t.integer :owned_quantity
      t.date :start_date
      t.float :start_price
      t.integer :start_amount
      t.date :end_date
      t.float :end_price
      t.integer :end_fee
      t.integer :end_amount
      t.float :pl_ratio
      t.integer :pl_amount
      t.text :memo
      t.string :market_category

      t.timestamps
    end
  end
end
