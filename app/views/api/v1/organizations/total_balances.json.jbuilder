json.total_amount money_with_symbol(@organization.total_balances.first[:total_amount])
json.default_currency @organization.total_balances.first[:default_currency]

json.totals @organization.total_balances.drop(1) do |balance|
  json.total balance[:total] ? money_with_symbol(balance[:total]) : nil
  json.currency balance[:currency]
  json.ex_total balance[:ex_total] ? money_with_symbol(balance[:ex_total]) : nil
  json.rate balance[:rate]
  json.updated_at balance[:updated_at].try(:iso8601)
end
