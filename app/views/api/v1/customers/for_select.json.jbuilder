json.array! @customers do |customer|
  json.value customer.id
  json.label customer.name
end
