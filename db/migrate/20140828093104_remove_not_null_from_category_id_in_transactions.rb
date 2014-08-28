class RemoveNotNullFromCategoryIdInTransactions < ActiveRecord::Migration
  def change
    change_column_null :transactions, :category_id, true
  end
end
