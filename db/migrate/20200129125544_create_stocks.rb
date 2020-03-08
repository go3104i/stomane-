class CreateStocks < ActiveRecord::Migration[6.0]
  def change
    create_table :stocks do |t|
      t.string :user_id
      t.string :trade_id
      t.string :stock_code
      t.string :stock_name
      t.string :transaction_type
      t.string :buy_sell
      t.integer :owned_quantity
      t.date :start_date
      t.float :start_price
      t.integer :start_fee
      t.integer :start_amount
      t.float :closing_price
      t.float :pl_ratio
      t.integer :pl_amount
      t.text :memo

      t.timestamps
    end
  end
end
