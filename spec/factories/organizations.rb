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
      owner                 nil
      with_user             nil
      without_bank_accounts false
      without_categories    false
    end

    after(:create) do |organization, evaluator|
      create :member, organization: organization, user: evaluator.with_user if evaluator.with_user
      create :bank_account, organization: organization unless evaluator.without_bank_accounts
      create :category, organization: organization unless evaluator.without_categories
      create :member, organization: organization, role: 'owner', user: evaluator.owner if evaluator.owner
    end
  end
end
