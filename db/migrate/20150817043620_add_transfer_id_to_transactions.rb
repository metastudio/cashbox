class AddTransferIdToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :transfer_id, :integer
  end
end
