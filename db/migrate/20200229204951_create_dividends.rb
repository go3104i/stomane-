class CreateDividends < ActiveRecord::Migration[6.0]
  def change
    create_table :dividends do |t|
      t.string :stock_code
      t.string :stock_name
      t.string :market_category
      t.string :dividend_type
      t.integer :dividend_quantity
      t.date :dividend_date
      t.float :dividend_price
      t.integer :dividend_amount

      t.timestamps
    end
  end
end
