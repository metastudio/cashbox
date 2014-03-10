class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.money :amount,                     null: false
      t.references :category, index: true, null: false
      t.references :invoice,  index: true, null: false

      t.timestamps
    end
  end
end
