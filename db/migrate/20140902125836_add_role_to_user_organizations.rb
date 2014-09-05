class AddRoleToUserOrganizations < ActiveRecord::Migration
  def change
    add_column :user_organizations, :role, :string
    ActiveRecord::Base.connection.execute("UPDATE user_organizations SET role='user'")
    change_column :user_organizations, :role, :string, null: false
  end
end
