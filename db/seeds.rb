# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts 'Create exchange rate ...'
ExchangeRate.create!(
  rates: Money.default_bank.rates,
  updated_from_bank_at: Money.default_bank.rates_updated_at
)

puts 'Create income and expense categories ...'
Category.create!(Category::CATEGORY_BANK_EXPENSE_PARAMS)
Category.create!(Category::CATEGORY_BANK_INCOME_PARAMS)

puts 'Create admin user ...'
user = User.create(
  email: 'admin@example.com',
  password: 'password',
  full_name: Faker::Name.name
)

puts 'Create user organization ...'
organization = FactoryGirl.create(
  :organization,
  owner: user,
  name: Faker::Company.name
)

puts 'Add more bank accounts ...'
FactoryGirl.create(
  :bank_account,
  organization: organization,
  currency: 'USD'
)

puts 'Create income transactions ...'
income_categories = 10.times.map do
  FactoryGirl.create(
    :category,
    :income,
    organization: organization,
  )
end

100.times do
  FactoryGirl.create(
    :transaction,
    :income,
    organization: organization,
    bank_account: organization.bank_accounts.sample,
    category: income_categories.sample,
    date: Faker::Date.between(1.years.ago, Date.today)
  )
end

puts 'Create expense transactions ...'
expense_categories = 4.times.map do
  FactoryGirl.create(
    :category,
    :expense,
    organization: organization,
  )
end

50.times do
  FactoryGirl.create(
    :transaction,
    :expense,
    organization: organization,
    bank_account: organization.bank_accounts.sample,
    category: expense_categories.sample,
    date: Faker::Date.between(1.years.ago, Date.today)
  )
end
