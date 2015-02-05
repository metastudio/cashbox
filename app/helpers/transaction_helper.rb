module TransactionHelper
  def bg_color(transaction)
    if transaction.bank_account.hidden?
      'bg-warning'
    else
      transaction.income? ? 'success' : 'danger'
    end
  end
end
