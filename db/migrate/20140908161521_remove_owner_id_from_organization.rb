class RemoveOwnerIdFromOrganization < ActiveRecord::Migration
  def self.up
    Organization.where.not(owner_id: nil).find_each do |org|
      unless org.members.find_by(user_id: org.owner_id, role: 'owner')
        org.members.create(user_id: org.owner_id, role: 'owner')
      end
    end
    remove_column :organizations, :owner_id, :integer
  end

  def self.down
    add_column :organizations, :owner_id, :integer
  end
end
