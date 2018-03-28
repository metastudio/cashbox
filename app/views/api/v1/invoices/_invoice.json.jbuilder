json.extract! invoice, :id, :number, :currency
json.starts_at l(invoice.starts_at) if invoice.starts_at.present?
json.ends_at l(invoice.ends_at)
json.sent_at l(invoice.sent_at) if invoice.sent_at.present?
json.paid_at l(invoice.paid_at) if invoice.paid_at.present?
json.amount money_with_symbol(invoice.amount)
json.income_transaction_presence invoice.income_transaction.present?
json.customer_name invoice.customer.to_s
json.invoice_details invoice_details
json.customer_details customer_details
json.invoice_items do
  json.partial! 'invoice_item', collection: invoice.invoice_items, as: :invoice_item
end
