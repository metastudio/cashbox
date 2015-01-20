class AddSystemToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :system, :boolean, default: false
  end
end
