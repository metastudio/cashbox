class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.references :owner, index: true

      t.timestamps
    end
  end
end
