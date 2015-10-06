class AddDateToInvoiceItems < ActiveRecord::Migration
  def change
    add_column :invoice_items, :date, :date
  end
end
