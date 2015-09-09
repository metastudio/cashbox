class RemoveAmountCurrencyFromInvoices < ActiveRecord::Migration
  def change
    remove_column :invoices, :amount_currency, :string
  end
end
