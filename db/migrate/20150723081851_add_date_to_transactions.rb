class AddDateToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :date, :datetime
    reversible do |dir|
      dir.up do
        Transaction.with_deleted.where(date: nil).update_all('date = created_at')
        change_column :transactions, :date, :datetime, null: false
      end
      dir.down do
      end
    end
    add_index :transactions, :date
  end
end
