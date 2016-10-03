json.array! @bank_accounts do |bank_account|
  json.value bank_account.id
  json.label bank_account.name
end
