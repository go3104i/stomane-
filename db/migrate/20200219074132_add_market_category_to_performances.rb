class AddMarketCategoryToPerformances < ActiveRecord::Migration[6.0]
  def change
    add_column :performances, :market_category, :string
  end
end
