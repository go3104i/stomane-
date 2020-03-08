class DropDividend < ActiveRecord::Migration[6.0]
  def change
    drop_table :dividends
  end
end
