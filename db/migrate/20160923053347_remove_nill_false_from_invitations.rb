class RemoveNillFalseFromInvitations < ActiveRecord::Migration[5.0]
  def up
    change_column :invitations, :invited_by_id, :integer,
      null: true, index: true
    change_column :invitations, :role, :string,
      null: true, index: true
  end

  def down
    change_column :invitations, :invited_by_id, :integer,
      null: false, index: true
    change_column :invitations, :role, :string,
      null: false, index: true
  end
end
