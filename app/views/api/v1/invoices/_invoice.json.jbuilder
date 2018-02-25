json.extract! invoice, :id, :starts_at, :ends_at, :sent_at, :paid_at, :number, :currency
json.amount money_with_symbol(invoice.amount)
json.income_transaction_presence invoice.income_transaction.present?
json.customer_name invoice.customer.to_s

json.invoice_items do
  json.partial! 'invoice_item', collection: invoice.invoice_items, as: :invoice_item
end