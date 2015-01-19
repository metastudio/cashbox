class RenameMemberIdColumnInInvitations < ActiveRecord::Migration
  def change
    rename_column :invitations, :member_id, :invited_by_id
  end
end
