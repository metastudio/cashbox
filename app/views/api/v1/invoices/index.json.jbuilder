# frozen_string_literal: true

json.invoices @invoices, partial: 'short_invoice', as: :invoice
json.unpaid_count @unpaid_count
json.pagination pagination_info(@invoices)
