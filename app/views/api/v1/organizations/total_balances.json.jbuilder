json.total_amount @organization.total_balances.first[:total_amount]
json.default_currency @organization.total_balances.first[:default_currency]

json.totals @organization.total_balances.drop(1) do |balance|
  json.total balance[:total]
  json.currency balance[:currency]
  json.ex_total balance[:ex_total]
  json.rate balance[:rate]
  json.updated_at balance[:updated_at]&.iso8601
end
