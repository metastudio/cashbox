class AddVisibleToBankAccounts < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :visible, :boolean, default: true
  end
end
