class CreateUnsubscribes < ActiveRecord::Migration[5.0]
  def change
    create_table :unsubscribes do |t|
      t.string :email
      t.boolean :active, default: false
      t.string :token
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
