class AddDateToTransactions < ActiveRecord::Migration
  def up
    add_column :transactions, :date, :datetime
    Transaction.all.find_each do |t|
      # especially without validations
      t.created_at ? t.update_attribute(:date, t.created_at) : t.update_attribute(:date, Time.now)
    end
    add_index :transactions, :date
  end

  def down
    remove_index :transactions, :date
    remove_column :transactions, :date, :datetime
  end
end
