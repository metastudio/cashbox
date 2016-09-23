json.(transaction, :id, :comission, :date, :comment)
json.amount money_with_symbol(transaction.amount)

json.category transaction.category, partial: 'api/v1/categories/short_category', as: :category
json.bank_account transaction.bank_account, partial: 'api/v1/bank_accounts/short_bank_account', as: :bank_account

if transaction.customer.present?
  json.customer transaction.customer, partial: 'api/v1/customers/short_customer', as: :customer
end

if transaction.invoice.present?
  json.invoice transaction.invoice, partial: 'api/v1/invoices/short_invoice', as: :invoice
end
