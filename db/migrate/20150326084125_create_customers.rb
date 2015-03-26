class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :name
      t.references :organization, index: true

      t.timestamps
    end
    add_index :customers, :name, unique: true
  end
end
