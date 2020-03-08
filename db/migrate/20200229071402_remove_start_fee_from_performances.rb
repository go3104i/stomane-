class RemoveStartFeeFromPerformances < ActiveRecord::Migration[6.0]
  def change

    remove_column :performances, :start_fee, :integer
    remove_column :performances, :net_pl_amount, :integer
  end
end
