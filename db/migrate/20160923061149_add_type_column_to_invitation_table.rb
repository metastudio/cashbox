class AddTypeColumnToInvitationTable < ActiveRecord::Migration[5.0]
  def change
    add_column :invitations, :type, :string
  end
end
