class AddNetPlAmountToPerformances < ActiveRecord::Migration[6.0]
  def change
    add_column :performances, :net_pl_amount, :integer
  end
end
