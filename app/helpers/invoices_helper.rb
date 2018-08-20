module InvoicesHelper
  def invoice_date_range(invoice)
    [invoice.starts_at, invoice.ends_at].compact.map{ |d| l d }.join(' - ')
  end

  def colorize_invoice(invoice)
    if invoice.completed?
      'paid'
    elsif invoice.overdue?
      'overdue'
    end
  end

  def unpaid_invoices
    current_organization.invoices.unpaid
  end
end
