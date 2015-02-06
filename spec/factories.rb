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

    ignore do
      with_user nil
    end

    after(:create) do |organization, evaluator|
      create :member, organization: organization, user: evaluator.with_user if evaluator.with_user
    end
  end

  factory :member do
    user
    organization

    trait :owner do
      role 'owner'
    end
  end

  sequence(:bank_account_name) { |n| "Bank account #{n}" }
  factory :bank_account do
    organization
    name { generate :bank_account_name }
    balance 0
    currency 'RUB'

    trait :with_transactions do
      after(:create) { |b| create_list :transaction, 2, bank_account: b, amount: 5000 }
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
  end

  factory :transaction do
    bank_account
    category
    amount { rand(100.00..200000.00) }

    trait :income do
      association :category, :income
    end

    trait :expense do
      association :category, :expense
    end
  end

  sequence(:bank_account_id)
  factory :transfer do
    bank_account_id { create(:bank_account, balance: 5000).id }
    reference_id    { create(:bank_account, balance: 5000).id }
    amount          500
    comission       50
    comment         "comment"
  end
end
