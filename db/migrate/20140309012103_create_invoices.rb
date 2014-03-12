class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.string :name,                               null: false
      t.string :description
      t.money :balance,                             null: false
      t.references :organization, index: true,      null: false

      t.timestamps
    end
  end
end