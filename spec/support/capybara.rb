require 'capybara/rspec'
require 'capybara/email/rspec'

Capybara.javascript_driver = :webkit

RSpec.configure do |config|
  config.after(:each, type: :feature) do
    Capybara.reset_sessions!
  end
end
