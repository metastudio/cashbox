class AddAcceptedToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :accepted, :boolean, default: false
  end
end
