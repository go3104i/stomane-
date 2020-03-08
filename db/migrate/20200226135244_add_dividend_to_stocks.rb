class AddDividendToStocks < ActiveRecord::Migration[6.0]
  def change
    add_column :stocks, :dividend, :integer
  end
end
