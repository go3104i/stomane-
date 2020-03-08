class RemoveNetPlAmountFromPerformances < ActiveRecord::Migration[6.0]
  def change

    remove_column :performances, :net_pl_amount, :integer
  end
end
