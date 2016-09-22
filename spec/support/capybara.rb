require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'capybara/email/rspec'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, window_size: [1200, 900], js_errors: false)
end

Capybara.javascript_driver = :poltergeist
Capybara.server_port = 8082

RSpec.configure do |config|
  config.after(:each) do
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
  end
  config.before(:each, js: true) do
    # page.driver.browser.url_blacklist = ['https://google.com', 'https://facebook.com']
  end
end
