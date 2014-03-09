class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :type,                          null: false
      t.string :name,                          null: false
      t.references :organization, index: true, null: false

      t.timestamps
    end
  end
end
