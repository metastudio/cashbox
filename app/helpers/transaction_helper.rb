module TransactionHelper
  def bg_color(transaction)
    if transaction.deleted_at.nil?
      transaction.income? ? 'success' : 'danger'
    else
      'bg-warning'
    end
  end
end
