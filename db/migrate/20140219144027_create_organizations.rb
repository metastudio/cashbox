class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.references :owner, null: false, index: true

      t.timestamps
    end
  end
end
