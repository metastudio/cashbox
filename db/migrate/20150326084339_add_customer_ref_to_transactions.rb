class AddCustomerRefToTransactions < ActiveRecord::Migration
  def change
    add_reference :transactions, :customer, index: true
  end
end
