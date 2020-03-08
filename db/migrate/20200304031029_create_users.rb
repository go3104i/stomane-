class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string "user_id"
      t.string "user_name"
      t.integer "stock_pl_amount"
      t.integer "dividend_pl_amount" 
      t.timestamps
    end
  end
end
