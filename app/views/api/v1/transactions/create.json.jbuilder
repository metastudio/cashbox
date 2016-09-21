json.transaction @transaction, partial: 'transaction', as: :transaction

json.transaction do
  json.category @transaction.category, :id, :name, :type
  json.bank_account @transaction.bank_account, :id, :name, :currency

  if @transaction.customer.present?
    json.customer @transaction.customer, :id, :name
  end

  if @transaction.invoice.present?
    json.invoice @transaction.invoice, :id, :starts_at, :ends_at, :amount_cents, :sent_at, :paid_at, :number
  end
end
