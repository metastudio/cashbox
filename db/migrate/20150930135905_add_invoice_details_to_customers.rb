class AddInvoiceDetailsToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :invoice_details, :text
  end
end
