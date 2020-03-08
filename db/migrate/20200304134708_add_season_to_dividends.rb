class AddSeasonToDividends < ActiveRecord::Migration[6.0]
  def change
    add_column :dividends, :season, :varchar
  end
end
