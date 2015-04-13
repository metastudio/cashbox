class UpdateTokenIndexToUniqToInvitations < ActiveRecord::Migration
  def change
    remove_index :invitations, :token
    add_index :invitations, :token, unique: true
  end
end
