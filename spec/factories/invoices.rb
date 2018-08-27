# frozen_string_literal: true
# == Schema Information
#
# Table name: invoices
#
#  id              :integer          not null, primary key
#  organization_id :integer          not null
#  customer_id     :integer          not null
#  starts_at       :date
#  ends_at         :date             not null
#  currency        :string           default("USD"), not null
#  amount_cents    :integer          default(0), not null
#  sent_at         :date
#  paid_at         :date
#  created_at      :datetime
#  updated_at      :datetime
#  number          :string
#  bank_account_id :integer
#

FactoryBot.define do
  factory :invoice do
    organization
    customer
    customer_name
    ends_at { Date.current }
    currency 'RUB'
    amount 500

    trait :with_items do
      invoice_items { create_list :invoice_item, 3 }
    end

    trait :unpaid do
      paid_at nil
    end

    trait :paid do
      paid_at { Time.current }
    end
  end
end
