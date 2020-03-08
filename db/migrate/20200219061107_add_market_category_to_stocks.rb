class AddMarketCategoryToStocks < ActiveRecord::Migration[6.0]
  def change
    add_column :stocks, :market_category, :string
  end
end
