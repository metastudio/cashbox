class RenameAmountCurrencyInInvoiceItems < ActiveRecord::Migration
  def change
    rename_column :invoice_items, :amount_currency, :currency
  end
end
