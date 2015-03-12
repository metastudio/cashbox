# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.destroy_all
Organization.destroy_all
BankAccount.destroy_all
Category.destroy_all
Transaction.destroy_all

Category.create!(Category::CATEGORY_BANK_EXPENSE_PARAMS)
Category.create!(Category::CATEGORY_BANK_INCOME_PARAMS)

user = User.create( email: "lukeiam@your.father",
             full_name: "Vader Lightsaber",
             password: "password" )

4.times do |i|
  org = Organization.create( name: "org#{i}" )
  org.members.create(user_id: user.id, role: 'owner')
end

15.times do |i|
  Category.create(type: ["Income", "Expense"].sample, name: "cat#{i}", organization_id: Organization.all.sample.id)
end

100.times do |i|
  BankAccount.create(  name: "bank_account#{i}",
                       balance: rand(10.00..50000).round(2),
                       currency: ["USD", "RUB", "EUR"].sample,
                       organization_id: Organization.all.sample.id )
end

250.times do |i|
  ba = BankAccount.all.sample
  trans = Transaction.create( amount: rand(10.00..50000).round(2),
                      bank_account_id: ba.id,
                      category: ba.organization.categories.sample,
                      transaction_type: "Residue" )
  trans.update_attribute(:created_at, rand((Time.now - 4.months)..Time.now))
end
