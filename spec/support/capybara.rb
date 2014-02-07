require 'capybara/rspec'
require 'capybara/email/rspec'

Capybara.javascript_driver = :webkit

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, :headers => { 'HTTP_ACCEPT_LANGUAGE' => 'en' })
end

RSpec.configure do |config|
  config.before(:each, js: true) do
    # Capybara webkit have a different way to set headers.
    page.driver.header("Accept-Language", "en")
  end
end
