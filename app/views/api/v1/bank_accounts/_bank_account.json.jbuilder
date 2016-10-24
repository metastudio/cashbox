json.extract! bank_account, :id, :name, :currency, :description, :invoice_details
json.balance money_with_symbol(bank_account.balance)
json.residue money_with_symbol(bank_account.residue)
