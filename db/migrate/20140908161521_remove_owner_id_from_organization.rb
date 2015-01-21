class RemoveOwnerIdFromOrganization < ActiveRecord::Migration
  Organization.where.not(owner_id: nil).find_each do |org|
    org.members.create(user_id: org.owner_id, role: 'owner')
  end

  def change
    remove_column :organizations, :owner_id, :integer
  end
end
