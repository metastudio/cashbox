class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.references :user, null: false
      t.string :full_name
      t.string :position
      t.string :avatar
      t.string :phone_number

      t.timestamps
    end

    add_index :profiles, :user_id, unique: true
  end
end
