require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/email/rspec'

require 'capybara-screenshot/rspec'

require 'selenium-webdriver'

RSpec.configure do |config|
  config.append_after(:each) do
    # Capybara.reset_sessions!    # Forget the (simulated) browser state
    # Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
  end
  config.before(:each, js: true) do
    # page.driver.browser.url_blacklist = ['https://google.com', 'https://facebook.com']
  end
end

# Keep only the screenshots generated from the last failing test suite
Capybara::Screenshot.prune_strategy = :keep_last_run

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    clear_session_storage: true,
    clear_local_storage: true,
    capabilities: [Selenium::WebDriver::Chrome::Options.new(
      args: %w[headless disable-gpu no-sandbox window-size=1024,768],
    )]
end

Capybara.javascript_driver = :chrome
# Capybara.default_max_wait_time = 5 # default: 2
# default capybara and dev server for Rails 5
Capybara.server = :puma, { Silent: true }
Capybara.server_port = 8082 + ENV['TEST_ENV_NUMBER'].to_i
Capybara.app_host = "http://localhost:#{Capybara.server_port}"
ActionController::Base.asset_host = Capybara.app_host

Capybara::Screenshot.register_driver(:chrome) do |driver, path|
  driver.browser.save_screenshot(path)
end
Capybara::Screenshot.webkit_options = { width: 1920, height: 2024 }
# Keep only the screenshots generated from the last failing test suite
Capybara::Screenshot.prune_strategy = :keep_last_run
