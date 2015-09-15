class EnlargeInvoicesAmount < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        change_column :invoices, :amount_cents, :bigint, default: 0, null: false
        change_column :invoice_items, :amount_cents, :bigint, default: 0, null: false
      end
      dir.down do
        change_column :invoices, :amount_cents, :integer, default: 0, null: false
        change_column :invoice_items, :amount_cents, :integer, default: 0, null: false
      end
    end
  end
end
