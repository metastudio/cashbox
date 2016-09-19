class AddCurrentOrganizationIdToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :current_organization_id, :integer
  end
end
