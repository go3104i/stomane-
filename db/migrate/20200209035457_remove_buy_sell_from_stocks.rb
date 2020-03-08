class RemoveBuySellFromStocks < ActiveRecord::Migration[6.0]
  def change

    remove_column :stocks, :buy_sell, :string
  end
end
