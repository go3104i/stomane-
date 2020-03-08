class RemoveDividendFromStocks < ActiveRecord::Migration[6.0]
  def change

    remove_column :stocks, :dividend, :integer
  end
end
