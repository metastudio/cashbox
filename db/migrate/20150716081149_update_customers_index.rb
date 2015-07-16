class UpdateCustomersIndex < ActiveRecord::Migration
  def up
    remove_index :customers, [:name, :organization_id]
    add_index :customers, [:name, :organization_id, :deleted_at], unique: true
  end

  def down
    add_index :customers, [:name, :organization_id], unique: true
    remove_index :customers, [:name, :organization_id, :deleted_at]
  end
end
