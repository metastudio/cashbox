# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Category.create!(Category::CATEGORY_BANK_EXPENSE_PARAMS)
Category.create!(Category::CATEGORY_BANK_INCOME_PARAMS)

begin
  bank = Money::Bank::RussianCentralBank.new
  bank.update_rates
  ExchangeRate.create(rates: bank.rates)
rescue Exception => e
  file = YAML.load(File.read(File.expand_path('../seeds/rates.yml', __FILE__)))
  rates = ExchangeRate.create(rates: file.rates)
  rates.update_attribute(:updated_at, file.updated_at)
end
