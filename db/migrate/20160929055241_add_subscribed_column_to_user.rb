class AddSubscribedColumnToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :subscribed, :boolean, default: true
  end
end
