class AddRootPageLastVisitedAtToMembers < ActiveRecord::Migration
  def change
    add_column :members, :root_page_last_visited_at, :datetime
  end
end
