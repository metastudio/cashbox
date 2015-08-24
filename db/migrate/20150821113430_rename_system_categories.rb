class RenameSystemCategories < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        Category.where(name: 'Transfer').update_all(name: 'Transfer out')
        Category.where(name: 'Receipt').update_all(name: 'Transfer')
      end
      dir.down do
        Category.where(name: 'Transfer').update_all(name: 'Receipt')
        Category.where(name: 'Transfer out').update_all(name: 'Transfer')
      end
    end
  end
end
