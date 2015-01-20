class AddReferenceIdToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :reference_id, :integer
  end
end
