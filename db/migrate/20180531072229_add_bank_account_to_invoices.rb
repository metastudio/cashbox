class AddBankAccountToInvoices < ActiveRecord::Migration[5.0]
  def change
    add_reference :invoices, :bank_account
  end
end
