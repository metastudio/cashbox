class MoveFullNameToUser < ActiveRecord::Migration
  def up
    add_column :users, :full_name, :string
    User.find_each do |user|
      user.update_attributes(full_name: user.profile.full_name)
    end
    change_column :users, :full_name, :string, null: false
    remove_column :profiles, :full_name
  end

  def down
    add_column :profiles, :full_name, :string
    User.find_each do |user|
      user.profile.update_attributes(full_name: user.full_name)
    end
    remove_column :users, :full_name
  end
end
