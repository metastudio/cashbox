class RemoveOwnerIdFromOrganization < ActiveRecord::Migration
  def change
    remove_column :organizations, :owner_id
  end
end
