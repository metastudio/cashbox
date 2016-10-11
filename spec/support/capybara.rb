require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'capybara/email/rspec'

Capybara.register_driver :poltergeist do |app|
  options = {
    port: 51674 + ENV['TEST_ENV_NUMBER'].to_i,
    window_size: [1200, 900],
    js_errors: true,
    phantomjs_logger: Logger.new(STDOUT)
  }
  Capybara::Poltergeist::Driver.new(app, options)
end

Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|
  config.append_after(:each) do
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
  end
  config.before(:each, js: true) do
    # page.driver.browser.url_blacklist = ['https://google.com', 'https://facebook.com']
  end
end
