class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.boolean :sended, default: false
      t.datetime :date
      t.string :kind
      t.references :notificator, polymorphic: true, index: true
      t.timestamps
    end
  end
end
