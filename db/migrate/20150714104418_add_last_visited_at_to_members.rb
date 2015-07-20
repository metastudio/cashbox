class AddLastVisitedAtToMembers < ActiveRecord::Migration
  def change
    add_column :members, :last_visited_at, :datetime
  end
end
