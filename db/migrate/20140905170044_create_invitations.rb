class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :token, null: false
      t.integer :user_id, null: false
      t.integer :organization_id, null: false

      t.timestamps
    end

    add_index :invitations, :token
    add_index :invitations, :user_id
    add_index :invitations, :organization_id
  end
end
