class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :name, null: false
      t.references :organization, index: true, null: false

      t.timestamps
    end
    add_index :customers, [:name, :organization_id], unique: true
  end
end
