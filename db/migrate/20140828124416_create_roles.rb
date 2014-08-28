class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.integer :user_id, null: false
      t.integer :organization_id, null: false

      t.timestamps
    end

    add_index :roles, :user_id
    add_index :roles, :organization_id
    add_index :roles, [:user_id, :organization_id], unique: true
  end
end
