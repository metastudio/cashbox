module InvoicesHelper
  def invoice_date_range(invoice)
    [invoice.starts_at, invoice.ends_at].compact.map{ |d| l d }.join(' - ')
  end

  def colorize_invoice(invoice)
    css_class = 'paid' if invoice.paid_at.present?
    css_class = 'overdue' if invoice.paid_at.nil? && Date.current - invoice.ends_at > 15
    css_class
  end
end
