json.invoices do
  json.array! @invoices, partial: 'invoice', as: :invoice
end
json.pagination @pagination
json.unpaid_count @unpaid_count
