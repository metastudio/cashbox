class AddInvoiceDetailsToBankAccounts < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :invoice_details, :text
  end
end
