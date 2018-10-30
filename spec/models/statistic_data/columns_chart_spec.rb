# frozen_string_literal: true

require 'rails_helper'

describe StatisticData::ColumnsChart do
  include DateLogic
  describe '#data_balance' do
    let(:org) { create :organization, default_currency: 'USD' }

    context 'def currency' do
      let(:account)       { create :bank_account, organization: org, currency: 'USD', residue: 9_999_999 }
      let(:other_account) { create :bank_account, organization: org, currency: 'RUB', residue: 0 }

      context 'current month' do
        let!(:transfer) { create :transfer, bank_account_id: account.id, reference_id: other_account.id, amount: 1000 }
        let!(:inc_transaction) { create :transaction, :income, bank_account: account }
        let!(:exp_transaction) { create :transaction, :expense, bank_account: account }
        let!(:old_transaction) { create :transaction, :income, bank_account: account, date: Date.current - 2.years }
        let(:total) { org.bank_accounts.total_balance(account.currency) + org.bank_accounts.total_balance(other_account.currency) }

        subject { StatisticData::ColumnsChart.new(org).data_balance[:data][13] }

        it 'has contaion current month, income, expense and total amounts for all months' do
          expect(subject).to eq [
            Date.current.strftime('%b, %Y'),
            inc_transaction.amount.to_f,
            exp_transaction.amount.abs.to_f,
            total.to_f,
          ]
        end
      end

      context 'current year' do
        let!(:transfer) { create :transfer, bank_account_id: account.id, reference_id: other_account.id, amount: 1000 }
        let!(:inc_transaction) { create :transaction, :income, bank_account: account }
        let!(:exp_transaction) { create :transaction, :expense, bank_account: account }
        let!(:old_transaction) { create :transaction, :income, bank_account: account, date: Date.current - 2.years }
        let(:total) { org.bank_accounts.total_balance(account.currency) + org.bank_accounts.total_balance(other_account.currency) }

        subject { StatisticData::ColumnsChart.new(org).data_balance('years')[:data].last }

        it 'has contaion current month, income, expense and total amounts for all months' do
          expect(subject).to eq [
            Date.current.strftime('%Y'),
            inc_transaction.amount.to_f,
            exp_transaction.amount.abs.to_f,
            total.to_f,
          ]
        end
      end

      context 'current quarter' do
        let!(:transfer) { create :transfer, bank_account_id: account.id, reference_id: other_account.id, amount: 1000 }
        let!(:inc_transaction) { create :transaction, :income, bank_account: account }
        let!(:exp_transaction) { create :transaction, :expense, bank_account: account }
        let!(:old_transaction) { create :transaction, :income, bank_account: account, date: Date.current - 2.years }
        let(:total) { org.bank_accounts.total_balance(account.currency) + org.bank_accounts.total_balance(other_account.currency) }

        subject { StatisticData::ColumnsChart.new(org).data_balance('quarters')[:data].last }

        it 'has contaion current month, income, expense and total amounts for all months' do
          expect(subject).to eq [
            get_quarter(Date.current.strftime('%b, %Y')),
            inc_transaction.amount.to_f,
            exp_transaction.amount.abs.to_f,
            total.to_f,
          ]
        end
      end

      context 'has contaion previous month, income, expense and total amounts' do
        let!(:inc_transaction) { create :transaction, :income, bank_account: account, date: Date.current - 1.month }
        let!(:exp_transaction) { create :transaction, :expense, bank_account: account, date: Date.current - 1.month }
        let(:total) { inc_transaction.amount.to_f - exp_transaction.amount.abs.to_f }

        subject { StatisticData::ColumnsChart.new(org).data_balance[:data][12] }

        it 'has contaion previous month, income, expense and total amounts for all months' do
          expect(subject).to eq [
            (Date.current - 1.month).strftime('%b, %Y'),
            inc_transaction.amount.to_f,
            exp_transaction.amount.abs.to_f,
            total.round(2),
          ]
        end
      end

      context 'has contaion previous year, income, expense and total amounts' do
        let!(:inc_transaction) { create :transaction, :income, bank_account: account, date: Date.current - 1.year }
        let!(:exp_transaction) { create :transaction, :expense, bank_account: account, date: Date.current - 1.year }
        let(:total) { inc_transaction.amount.to_f - exp_transaction.amount.abs.to_f }

        subject { StatisticData::ColumnsChart.new(org).data_balance('years')[:data][-2] }

        it 'has contaion previous year, income, expense and total amounts for all months' do
          expect(subject).to eq [
            (Date.current - 1.year).strftime('%Y'),
            inc_transaction.amount.to_f,
            exp_transaction.amount.abs.to_f,
            total.round(2),
          ]
        end
      end

      context 'has contaion previous quarter, income, expense and total amounts' do
        let!(:inc_transaction) { create :transaction, :income, bank_account: account, date: Date.current - 3.months }
        let!(:exp_transaction) { create :transaction, :expense, bank_account: account, date: Date.current - 3.months }
        let(:total) { inc_transaction.amount.to_f - exp_transaction.amount.abs.to_f }

        subject { StatisticData::ColumnsChart.new(org).data_balance('quarters')[:data][-2] }

        it 'has contaion previous quarter, income, expense and total amounts for all months' do
          expect(subject).to eq [
            get_quarter((Date.current - 3.months).strftime('%b, %Y')),
            inc_transaction.amount.to_f,
            exp_transaction.amount.abs.to_f,
            total.round(2),
          ]
        end
      end
    end
  end

  describe '#customers_by_months' do
    let!(:org) { create :organization, default_currency: 'RUB' }
    let!(:customer1) { create :customer, organization: org }
    let!(:customer2) { create :customer, organization: org }
    let!(:category) { create :category, :income, organization: org }
    let!(:transaction1) do
      create :transaction, :income, organization: org, customer: customer1, category: category
    end
    let!(:transaction2) do
      create :transaction, :income, organization: org, customer: customer2, category: category
    end

    context 'current month' do
      subject { StatisticData::ColumnsChart.new(org).customers_by_months[:data].last }

      it 'have data about transactions in current month' do
        expect(subject).to match_array [
          Date.current.strftime('%b, %Y'),
          (transaction1.amount.cents / 100).round(2),
          (transaction2.amount.cents / 100).round(2),
          '',
        ]
      end
    end

    context 'previous month' do
      let!(:transaction3) do
        create :transaction, :income,
          organization: org,
          customer:     customer1,
          category:     category,
          date:         Date.current - 1.month
      end
      let!(:transaction4) do
        create :transaction, :income,
          organization: org,
          customer:     customer2,
          category:     category,
          date:         Date.current - 1.month
      end
      subject { StatisticData::ColumnsChart.new(org).customers_by_months[:data][-2] }

      it 'have data about transactions in previous month' do
        expect(subject).to match_array [
          (Date.current - 1.month).strftime('%b, %Y'),
          (transaction3.amount.cents / 100).round(2),
          (transaction4.amount.cents / 100).round(2),
          '',
        ]
      end
    end

    context 'organization have transaction with different currency' do
      let!(:account) { create :bank_account, organization: org, currency: 'USD' }
      let!(:customer3) { create :customer, organization: org }
      let!(:transaction3) do
        create :transaction, :income,
          organization: org,
          customer:     customer3,
          category:     category,
          bank_account: account
      end

      subject { StatisticData::ColumnsChart.new(org).customers_by_months[:data].last }

      it 'convert amounts to organization currency' do
        expect(subject).to match_array [
          Date.current.strftime('%b, %Y'),
          (transaction1.amount.cents / 100).round(2),
          (transaction2.amount.cents / 100).round(2),
          (transaction3.amount.exchange_to('RUB').cents / 100).round(2),
          '',
        ]
      end
    end

    context 'transaction without customer' do
      let!(:transaction3) do
        create :transaction, :income,
          organization: org,
          customer:     nil,
          category:     category
      end

      subject { StatisticData::ColumnsChart.new(org).customers_by_months[:data].last }

      it 'have data about transactions in current month' do
        expect(subject).to match_array [
          Date.current.strftime('%b, %Y'),
          (transaction1.amount.cents / 100).round(2),
          (transaction2.amount.cents / 100).round(2),
          '',
        ]
      end
    end

    context 'organization has transaction in 2014' do
      let!(:transaction3) do
        create :transaction, :income,
          organization: org,
          customer:     customer1,
          category:     category,
          date:         Date.parse('02.02.2014')
      end

      subject { StatisticData::ColumnsChart.new(org).customers_by_months[:data].last }

      it 'not rised error' do
        expect(subject).to match_array [
          Date.current.strftime('%b, %Y'),
          (transaction1.amount.cents / 100).round(2),
          (transaction2.amount.cents / 100).round(2),
          '',
        ]
      end
    end
  end
end
