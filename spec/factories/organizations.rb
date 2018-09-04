# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id               :integer          not null, primary key
#  name             :string(255)      not null
#  created_at       :datetime
#  updated_at       :datetime
#  default_currency :string(255)      default("USD")
#

FactoryBot.define do
  sequence(:organization_name) { |n| "Organization #{n}" }

  factory :organization do
    name { generate :organization_name }

    transient do
      user                  nil
      owner                 nil
      with_user             nil
      without_bank_accounts false
      without_categories    false
    end

    after(:create) do |org, evaluator|
      [*evaluator.user].each do |u|
        create :member, organization: org, user: u
      end
      [*evaluator.owner].each do |u|
        create :member, organization: org, user: u, role: 'owner'
      end
      create :member, organization: org, user: evaluator.with_user if evaluator.with_user
      create :bank_account, organization: org unless evaluator.without_bank_accounts
      create :category, organization: org unless evaluator.without_categories
    end
  end
end
