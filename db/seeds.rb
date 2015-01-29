


User.destroy_all
Organization.destroy_all
BankAccount.destroy_all
Category.destroy_all
Transaction.destroy_all


user = User.create( email: "lukeiam@your.father",
  full_name: "Vader Lightsaber",
  password: "maytheforcebewithyou" )

50.times do |i|
  org = Organization.create( name: "org#{i}" )
  org.members.create(user_id: user.id, role: 'owner' )
end

200.times do |i|
  Category.create(type: "Income", name: "cat#{i}",
    organization_id: Organization.all.sample.id )
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
