class AddRoleToUserOrganizations < ActiveRecord::Migration
  def change
    add_column :user_organizations, :role, :string
  end
end
