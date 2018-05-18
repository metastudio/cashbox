require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/email/rspec'

Capybara.javascript_driver = :webkit

Capybara::Webkit.configure do |config|
  # Silently return an empty 200 response for any requests to unknown URLs.
  config.block_unknown_urls
end

RSpec.configure do |config|
  config.append_after(:each) do
    # Capybara.reset_sessions!    # Forget the (simulated) browser state
    # Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
  end
  config.before(:each, js: true) do
    # page.driver.browser.url_blacklist = ['https://google.com', 'https://facebook.com']
  end
end
