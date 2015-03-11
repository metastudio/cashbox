class EnlargeMoneyTypes < ActiveRecord::Migration
  def up
    change_column :bank_accounts, :balance_cents, :bigint, default: 0, null: false
    change_column :transactions, :amount_cents, :bigint, default: 0, null: false
  end

  def down
    change_column :bank_accounts, :balance_cents, :integer, default: 0, null: false
    change_column :transactions, :amount_cents, :integer, default: 0, null: false
  end
end
