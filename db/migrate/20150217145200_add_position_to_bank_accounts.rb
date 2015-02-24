class AddPositionToBankAccounts < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :position, :integer
  end
end
