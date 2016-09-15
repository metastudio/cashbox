class AddUserToTransaction < ActiveRecord::Migration[5.0]
  def change
    add_reference :transactions, :created_by, index: true
  end
end
