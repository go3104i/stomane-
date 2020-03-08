class CreateStockmasters < ActiveRecord::Migration[6.0]
  def change
    create_table :stockmasters do |t|
      t.string :update_date
      t.string :stock_code
      t.string :stock_name
      t.string :market_category
      t.string :industry_code_33
      t.string :industry_category_33
      t.string :industry_code_17
      t.string :industry_category_17
      t.string :scale_code
      t.string :scale_category

      t.timestamps   
    end
  end
end
