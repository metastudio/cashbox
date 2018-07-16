json.extract! transfer_out, :id, :amount, :comment, :comission, :date, :created_at

json.category transfer_out.category, partial: 'api/v1/categories/short_category', as: :category
json.bank_account transfer_out.bank_account, partial: 'api/v1/bank_accounts/short_bank_account', as: :bank_account

if transfer_out.customer.present?
  json.customer transfer_out.customer, partial: 'api/v1/customers/short_customer', as: :customer
end
