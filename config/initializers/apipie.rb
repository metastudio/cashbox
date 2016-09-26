Apipie.configure do |config|
  config.app_name                = 'Cashbox'
  config.app_info                = 'Cashbox API'
  config.api_base_url            = ''
  config.doc_base_url            = '/apipie'
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
  config.default_version         = '1'
  config.validate                = false
end
