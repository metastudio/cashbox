class UpdateTransactionsWithDeletedCustomers < ActiveRecord::Migration
  def up
    Transaction.where('customer_id IN (?)', Customer.only_deleted.pluck(:id)).update_all(customer_id: nil)
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Can't recover transaction's customer_id"
  end
end
