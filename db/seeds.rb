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


user = User.create( email: "lukeiam@your.father",
             full_name: "Vader Lightsaber",
             password: "password" )

50.times do |i|
  Organization.create(
    name: "org#{i}",
    owner_id: User.first.id )
end

200.times do |i|
  Category.create(type: "Income", name: "cat#{i}", organization_id: Organization.all.sample.id)
end

200.times do |i|
  BankAccount.create( name: "bank_account#{i}",
                       balance: rand(10.00..50000).round(2),
                       currency: ["USD", "RUB"].sample,
                       organization_id: Organization.all.sample.id )
end

500.times do |i|
  Transaction.create( amount: rand(10.00..50000).round(2),
                      category: Category.all.sample,
                      bank_account_id: BankAccount.all.sample.id,
                      transaction_type: "Residue" )
end
