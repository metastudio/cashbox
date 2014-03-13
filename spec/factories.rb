FactoryGirl.define do
  sequence(:email)     { |n| "user#{n}@cashbox.dev" }
  sequence(:password)  { SecureRandom.hex(10) }
  sequence(:full_name) { |n| "Test User#{n}" }
  factory :user do
    email
    password
    full_name

    trait :with_organization do
      after(:create) { |u| create :user_organization, user: u }
    end

    trait :with_organizations do
      after(:create) { |u| create_list :user_organization, 3, user: u }
    end
  end

  sequence(:organization_name) { |n| "Organization #{n}" }
  factory :organization do |o|
    name { generate :organization_name }
    association :owner, factory: :user
  end

  factory :user_organization do
    user
    organization
  end
end
