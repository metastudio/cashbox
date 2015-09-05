module InvoicesHelper
  def invoice_date_range(invoice)
    [invoice.starts_at, invoice.ends_at].compact.map{ |d| l d }.join(' - ')
  end
end
