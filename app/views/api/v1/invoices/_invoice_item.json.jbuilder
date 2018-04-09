# frozen_string_literal: true

json.extract! invoice_item, :description, :hours, :currency, :date, :amount
json.customer_name invoice_item.customer.to_s if invoice_item.customer.present?
