class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :token, null: false
      t.string :email, null: false
      t.string :role, null: false
      t.integer :member_id, null: false

      t.timestamps
    end

    add_index :invitations, :token
    add_index :invitations, :member_id
  end
end
