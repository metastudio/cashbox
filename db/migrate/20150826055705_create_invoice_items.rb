class CreateInvoiceItems < ActiveRecord::Migration
  def change
    create_table :invoice_items do |t|
      t.references :invoice, index: true, null: false
      t.references :customer
      t.monetize :amount, null: false
      t.decimal :hours
      t.text :description

      t.timestamps
    end
  end
end
