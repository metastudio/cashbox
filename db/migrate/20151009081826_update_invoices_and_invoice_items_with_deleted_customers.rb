class UpdateInvoicesAndInvoiceItemsWithDeletedCustomers < ActiveRecord::Migration
  def up
    InvoiceItem.where('customer_id IN (?)', Customer.only_deleted.pluck(:id)).update_all(customer_id: nil)
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Can't recover invoice_item's customer_id"
  end
end
