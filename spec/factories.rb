# frozen_string_literal: true

FactoryBot.define do
  sequence(:transaction_comment) { |n| "Test transaction comment #{n}" }
  sequence(:phone_number) { "+15555555#{rand(100..999)}" }
  sequence(:invoice_details) { |n| "«TestBank» Bank S.W.I.F.T. TESTRU2K #{n}" }

  sequence(:organization_name) { |n| "Organization #{n}" }
  factory :organization do
    name { generate :organization_name }

    transient do
      owner nil
      with_user nil
      without_categories false
    end

    after(:create) do |organization, evaluator|
      create :member, organization: organization, user: evaluator.with_user if evaluator.with_user
      create :bank_account, organization: organization
      create :category, organization: organization unless evaluator.without_categories
      create :member, organization: organization, role: 'owner', user: evaluator.owner if evaluator.owner
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
    invoice_details { generate :invoice_details }
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

    trait :receipt do
      type 'Income'
      name 'Receipt'
      system true
    end
  end

  sequence(:customer_name) { |n| "Customer #{n}" }

  factory :customer do
    organization
    name { generate :customer_name }
    invoice_details { generate :invoice_details }
  end

  factory :invitation do
    email   { build(:user).email }
    invited_by  { create :user }
    accepted { false }
  end

  factory :organization_invitation do
    email   { create(:user).email }
    role    { Member.role.default_value }
    invited_by  { create :member }
    accepted { false }
  end

  factory :profile do
    user { build :user }
  end
end
