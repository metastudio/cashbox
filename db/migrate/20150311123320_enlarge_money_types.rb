class EnlargeMoneyTypes < ActiveRecord::Migration
  def change
    change_column :bank_accounts, :balance_cents, :bigint, default: 0, null: false
    change_column :transactions, :amount_cents, :bigint, default: 0, null: false
  end
end
