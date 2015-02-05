class AddHiddenToBankAccounts < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :hidden, :boolean, default: false
  end
end
