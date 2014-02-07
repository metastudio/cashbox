RSpec.configure do |config|
  config.before(:each, js: true) do
    Headless.new.start
  end
end
