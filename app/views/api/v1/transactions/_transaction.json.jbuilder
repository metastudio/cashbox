# frozen_string_literal: true

transaction = transaction.transfer_in if transaction.transfer_out? && transaction.transfer_in

json.extract!(
  transaction,
  :id,
  :category_id,
  :bank_account_id,
  :customer_id,
  :comission,
  :date,
  :comment,
  :amount,
  :invoice_id,
  :updated_at,
  :created_at,
)

json.category transaction.category, partial: 'api/v1/categories/short_category', as: :category
json.bank_account transaction.bank_account, partial: 'api/v1/bank_accounts/short_bank_account', as: :bank_account

if transaction.customer.present?
  json.customer transaction.customer, partial: 'api/v1/customers/short_customer', as: :customer
end

if transaction.transfer_out.present?
  json.transfer_out transaction.transfer_out, partial: 'transfer_out', as: :transfer_out
end

if transaction.invoice.present?
  json.invoice transaction.invoice, partial: 'api/v1/invoices/short_invoice', as: :invoice
end

json.is_viewed transaction.viewed_for_member?(current_member)
