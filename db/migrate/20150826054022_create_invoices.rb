class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.references :organization, index: true, null: false
      t.references :customer, index: true, null: false
      t.datetime :starts_at
      t.datetime :ends_at, null: false
      t.string :currency, null: false, default: 'USD'
      t.monetize :amount, null: false
      t.datetime :sent_at
      t.datetime :paid_at

      t.timestamps
    end
  end
end
