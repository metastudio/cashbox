class RemoveCurrencyFromTransaction < ActiveRecord::Migration
  def change
    remove_column :transactions, :amount_currency, :string
  end
end
