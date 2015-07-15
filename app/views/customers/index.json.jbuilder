json.array!(@customers) do |customer|
  json.extract! customer, :id, :name
  json.url ccustomer_url(customer, format: :json)
end
