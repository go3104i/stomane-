class AddMemoToDividends < ActiveRecord::Migration[6.0]
  def change
    add_column :dividends, :memo, :text
  end
end
