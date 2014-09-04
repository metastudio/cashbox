class RenameUserOrganizationsToMembers < ActiveRecord::Migration
  def change
    rename_table :user_organizations, :members
  end
end
