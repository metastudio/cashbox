# frozen_string_literal: true

json.extract! invoice, :id, :number, :currency, :starts_at, :ends_at, :sent_at,
  :paid_at, :amount, :invoice_details, :customer_details, :customer_name, :customer_id,
  :bank_account_id
json.has_income_transaction invoice.has_income_transaction?
json.invoice_items do
  json.partial! 'invoice_item', collection: invoice.invoice_items, as: :invoice_item
end
