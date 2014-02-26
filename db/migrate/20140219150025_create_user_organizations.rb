class CreateUserOrganizations < ActiveRecord::Migration
  def change
    create_table :user_organizations do |t|
      t.references :user, null: false
      t.references :organization, null: false

      t.timestamps
    end

    add_index :user_organizations, [:user_id, :organization_id], unique: true
  end
end
