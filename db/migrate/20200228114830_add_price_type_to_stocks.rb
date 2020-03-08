class AddPriceTypeToStocks < ActiveRecord::Migration[6.0]
  def change
    add_column :stocks, :price_type, :varchar
  end
end
