# frozen_string_literal: true

json.extract! invoice_item, :id, :description, :hours, :currency, :date, :amount, :customer_id
json.customer_name invoice_item.customer.to_s if invoice_item.customer.present?
