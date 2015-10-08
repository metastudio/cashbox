class UpdateTransactionsWithDeletedCustomers < ActiveRecord::Migration
  def change
    Transaction.where('customer_id IN (?)', Customer.only_deleted.pluck(:id)).update_all(customer_id: nil)
  end
end
