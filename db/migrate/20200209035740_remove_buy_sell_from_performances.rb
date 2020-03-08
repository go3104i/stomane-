class RemoveBuySellFromPerformances < ActiveRecord::Migration[6.0]
  def change
    remove_column :performances, :buy_sell, :string
  end
end
