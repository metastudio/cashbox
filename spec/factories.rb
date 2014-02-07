FactoryGirl.define do
  sequence(:email) { |n| "user#{n}@cashbox.dev" }
  factory :user do
    email
    password 'passw0rd'
  end
end
