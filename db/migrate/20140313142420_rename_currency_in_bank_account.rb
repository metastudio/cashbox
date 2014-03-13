class RenameCurrencyInBankAccount < ActiveRecord::Migration
  def change
    rename_column :bank_accounts, :balance_currency, :currency
  end
end
