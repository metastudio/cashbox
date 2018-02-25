json.extract! invoice_item, :description, :hours, :currency, :date
json.amount money_with_symbol(invoice_item.amount)
json.customer_to_s invoice_item.customer.to_s if invoice_item.customer.present?