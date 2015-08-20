RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
    # Create system categories before each
    Category.create!(Category::CATEGORY_BANK_EXPENSE_PARAMS)
    Category.create!(Category::CATEGORY_BANK_INCOME_PARAMS)
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
