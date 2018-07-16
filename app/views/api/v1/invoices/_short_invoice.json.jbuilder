# frozen_string_literal: true

json.extract! invoice, :id, :starts_at, :ends_at, :amount, :sent_at, :paid_at,
  :number, :customer_name
