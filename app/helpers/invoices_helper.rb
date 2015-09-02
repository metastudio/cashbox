module InvoicesHelper
  def invoice_date_range(invoice)
    if invoice.starts_at
      (l invoice.starts_at).to_s + ' - ' + (l invoice.ends_at).to_s
    else
      l invoice.ends_at
    end
  end
end
