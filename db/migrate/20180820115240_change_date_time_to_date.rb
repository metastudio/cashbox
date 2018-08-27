# frozen_string_literal: true

class ChangeDateTimeToDate < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      dir.up do
        change_column :transactions, :date, :date, null: false
        change_column :invoices, :sent_at, :date
        change_column :invoices, :paid_at, :date
      end
      dir.down do
        change_column :transactions, :date, :datetime, null: false
        change_column :invoices, :sent_at, :datetime
        change_column :invoices, :paid_at, :datetime
      end
    end
  end
end
