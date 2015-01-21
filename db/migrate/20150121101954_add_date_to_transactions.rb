class AddDateToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions, :date, :datetime

    Transaction.find_each do |trans|
      trans.update_attribute(:date, trans.created_at)
    end
  end

  def self.down
    remove_column :transactions, :date, :datetime
  end
end
