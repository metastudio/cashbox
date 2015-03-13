# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
ExchangeRate.create!(
  rates: Money.default_bank.rates,
  updated_from_bank_at: Money.default_bank.rates_updated_at
)

Category.create!(Category::CATEGORY_BANK_EXPENSE_PARAMS)
Category.create!(Category::CATEGORY_BANK_INCOME_PARAMS)
