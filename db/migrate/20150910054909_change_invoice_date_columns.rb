class ChangeInvoiceDateColumns < ActiveRecord::Migration
  def change
    change_column :invoices, :starts_at, :date
    change_column :invoices, :ends_at, :date
  end
end
