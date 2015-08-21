class AddTransferIdToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :transfer_out_id, :integer
  end
end
