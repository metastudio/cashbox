# frozen_string_literal: true

FactoryBot.define do
  factory :transfer do
    bank_account_id { create(:bank_account, balance: 99999, currency: 'USD').id }
    reference_id    { |t| create(:bank_account, organization: BankAccount.find(t.bank_account_id).organization).id }
    from_currency   { 'USD' }
    to_currency     { 'USD' }
    amount          { 500 }
    comission       { 50 }
    comment         { 'comment' }

    trait :with_different_currencies do
      bank_account_id { create(:bank_account, balance: 99999, currency: 'USD').id }
      reference_id    { |t| create(:bank_account, currency: 'RUB', organization: BankAccount.find(t.bank_account_id).organization).id }
      from_currency   { 'USD' }
      to_currency     { 'RUB'}
      exchange_rate   { 0.5 }
    end
  end
end
