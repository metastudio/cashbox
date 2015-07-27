FactoryGirl.define do
  sequence(:email)     { |n| "user#{n}@cashbox.dev" }
  sequence(:password)  { SecureRandom.hex(10) }
  sequence(:full_name) { |n| "Test User#{n}" }
  sequence(:transaction_comment) { |n| "Test transaction comment #{n}" }
  sequence(:phone_number) { |n| "12345#{n}" }
  factory :user do
    email
    password
    full_name

    trait :with_organization do
      after(:create) { |u| create :member, user: u }
    end

    trait :with_organizations do
      after(:create) { |u| create_list :member, 3, user: u }
    end
  end

  sequence(:organization_name) { |n| "Organization #{n}" }
  factory :organization do |o|
    name { generate :organization_name }

    transient do
      with_user nil
    end

    after(:create) do |organization, evaluator|
      create :member, organization: organization, user: evaluator.with_user if evaluator.with_user
    end
  end

  factory :member do
    user
    organization

    trait :admin do
      role 'admin'
    end

    trait :owner do
      role :owner
    end

    trait :user do
      role :user
    end
  end

  sequence(:bank_account_name) { |n| "Bank account #{n}" }
  factory :bank_account do
    organization
    name { generate :bank_account_name }
    balance 0
    currency 'RUB'

    trait :with_transactions do
      after(:create) { |b| create_list :transaction, 2, bank_account: b, amount: 50000 }
    end

    trait :full do
      after(:create) { |b| create :transaction, bank_account: b, amount: Dictionaries.money_max }
    end
  end

  sequence(:category_name) { |n| "Category #{n}" }
  factory :category do
    organization
    name { generate :category_name }
    type 'Income'

    trait :income do
      type 'Income'
    end

    trait :expense do
      type 'Expense'
    end

    trait :transfer do
      type 'Expense'
      name 'Transfer'
      system true
    end
  end

  sequence(:customer_name) { |n| "Customer #{n}" }
  factory :customer do
    organization
    name { generate :customer_name }
  end

  factory :transaction do
    bank_account
    category { |t| create(:category, organization: t.bank_account.organization) }
    amount { rand(30000.0..50000)/rand(10.0..100) }

    trait :income do
      category { |t| create(:category, :income, organization: t.organization) }
    end

    trait :expense do
      category { |t| create(:category, :expense, organization: t.organization) }
    end

    trait :with_customer do
      customer { |t| create(:customer, organization: t.organization) }
    end
  end

  factory :transfer do
    bank_account_id { create(:bank_account, balance: 99999, currency: 'USD').id }
    reference_id    { |t| create(:bank_account,
      organization: BankAccount.find(t.bank_account_id).organization).id }
    from_currency   { 'USD' }
    to_currency     { 'USD' }
    amount          500
    comission       50
    comment         "comment"

    trait :with_different_currencies do
      bank_account_id { create(:bank_account, balance: 99999, currency: 'USD').id }
      reference_id    { |t| create(:bank_account, currency: 'RUB',
        organization: BankAccount.find(t.bank_account_id).organization).id }
      from_currency   { 'USD' }
      to_currency     { 'RUB'}
      exchange_rate   0.5
    end
  end

  factory :invitation do
    email   { create(:user).email }
    role    { Member.role.default_value }
    member  { create :member }
    accepted { false }
  end
end
