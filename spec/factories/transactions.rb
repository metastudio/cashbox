# frozen_string_literal: true

# == Schema Information
#
# Table name: transactions
#
#  id               :integer          not null, primary key
#  amount_cents     :integer          default(0), not null
#  category_id      :integer
#  bank_account_id  :integer          not null
#  created_at       :datetime
#  updated_at       :datetime
#  comment          :string(255)
#  transaction_type :string(255)
#  deleted_at       :datetime
#  customer_id      :integer
#  date             :date             not null
#  transfer_out_id  :integer
#  invoice_id       :integer
#  created_by_id    :integer
#

FactoryBot.define do
  sequence(:transaction_comment) { |i| "Test transaction #{i}" }
  sequence(:transaction_amount)  { Money.from_amount(rand(30_000.0..50_000.0) / rand(10.0..100.0)) }

  factory :transaction do
    organization
    bank_account { |t| create :bank_account, organization: t.organization }
    category     { |t| create(:category, organization: t.bank_account.organization) }
    amount       { generate :transaction_amount }
    date         { Date.current }
    comment      { generate :transaction_comment }

    trait :income do
      category { |t| create(:category, :income, organization: t.bank_account.organization) }
    end

    trait :expense do
      category { |t| create(:category, :expense, organization: t.bank_account.organization) }
    end

    trait :with_customer do
      customer { |t| create(:customer, organization: t.bank_account.organization) }
    end
  end
end
