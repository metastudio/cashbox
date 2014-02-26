FactoryGirl.define do
  sequence(:email) { |n| "user#{n}@cashbox.dev" }
  factory :user do
    email
    password 'passw0rd'
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
