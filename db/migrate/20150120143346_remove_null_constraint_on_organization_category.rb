class RemoveNullConstraintOnOrganizationCategory < ActiveRecord::Migration
  def change
    change_column :categories, :organization_id, :integer, null: true
  end
end
