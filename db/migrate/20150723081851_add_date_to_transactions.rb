class AddDateToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :date, :datetime
    reversible do |dir|
      dir.up do
        Transaction.with_deleted.update_all('date = created_at')
        change_column :transactions, :date, :datetime, null: false
      end
    end
    add_index :transactions, :date
  end
end
