class AddRoleToUserOrganizations < ActiveRecord::Migration
  def change
    add_column :user_organizations, :role, :string
    UserOrganization.update_all role: 'user'
    change_column :user_organizations, :role, :string, null: false
  end
end
