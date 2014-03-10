module InvoicesHelper
  def total_balance(invoices)
    invoices.map(&:balance).sum
  end
end
