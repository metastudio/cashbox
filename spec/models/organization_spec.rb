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

require 'rails_helper'
include DateLogic

describe Organization do
  context 'association' do
    it { should have_many(:owners).class_name('User').through(:members) }
    it { should have_many(:members).dependent(:destroy) }
    it { should have_many(:bank_accounts).dependent(:destroy) }
    it { should have_many(:users).through(:members) }
    it { should have_many(:categories).dependent(:destroy) }
    it { should have_many(:transactions).through(:bank_accounts) }
    it { expect(subject).to have_many(:customers).dependent(:destroy) }
    it { is_expected.to have_many(:invitations).through(:members).
      source(:created_invitations).dependent(:destroy) }
  end

  context 'validation' do
    it { should validate_presence_of(:name) }
  end

  describe '#exchange_rates' do
    before do
      Dictionaries.currencies << 'JPY' unless Dictionaries.currencies.include?('JPY')
    end

    after do
      Dictionaries.currencies.delete('JPY') if Dictionaries.currencies.include?('JPY')
    end

    context 'with updated Dictionary for including JPY' do
      let!(:org) { create :organization }
      let!(:ba)  { create :bank_account, currency: 'USD', organization: org }
      let!(:ba2) { create :bank_account, currency: 'RUB', organization: org }
      let!(:ba3) { create :bank_account, currency: 'EUR', organization: org }
      let!(:ba4) { create :bank_account, currency: 'JPY', organization: org }

      # ToDo needs to be updated when we change default bank
      # should contain then each-to-each currency keys e.x. USD_TO_EUR
      # not only within RUB
      it 'return only present currency rates' do
        expect(org.exchange_rates.keys).to eq ['RUB_TO_USD', 'USD_TO_RUB', 'RUB_TO_EUR', 'EUR_TO_RUB',
          'RUB_TO_JPY', 'JPY_TO_RUB', 'EUR_TO_USD', 'USD_TO_EUR']
      end
    end
  end

  describe '#ordered_curr' do
    let!(:org) { create :organization, default_currency: curr }
    let!(:ba)  { create :bank_account, currency: 'USD', organization: org }
    let!(:ba2) { create :bank_account, currency: 'RUB', organization: org }

    context 'when def curr = USD' do
      let(:curr) { 'USD' }
      it 'is correct' do
        expect(org.ordered_curr).to eq [curr, 'RUB']
      end
    end

    context 'when def curr = RUB' do
      let(:curr) { 'RUB' }
      it 'is correct' do
        expect(org.ordered_curr).to eq [curr, 'USD']
      end
    end
  end

  describe "#data_balance" do
    let(:org) { create :organization, default_currency: 'USD' }

    context 'def currency' do
      let(:account){ create :bank_account, organization: org, currency: 'USD',
        residue: 9999999 }
      let(:other_account) { create :bank_account, organization: org, currency: 'RUB', residue: 0 }

      context 'current month' do
        let!(:transfer) { create :transfer, bank_account_id: account.id, reference_id: other_account.id,
          amount: 1000 }
        let!(:inc_transaction) { create :transaction, :income, bank_account: account }
        let!(:exp_transaction) { create :transaction, :expense, bank_account: account }
        let!(:old_transaction) { create :transaction, :income, bank_account: account,
          date: Date.current - 2.years }
        let(:total) { org.bank_accounts.total_balance(account.currency) +
          org.bank_accounts.total_balance(other_account.currency) }

        subject { org.data_balance[:data][13] }

        it 'has contaion current month, income, expense and total amounts for all months' do
          expect(subject).to eq [Date.current.strftime("%b, %Y"),
            inc_transaction.amount.to_f, exp_transaction.amount.abs.to_f, total.to_f]
        end
      end

      context 'current year' do
        let!(:transfer) { create :transfer, bank_account_id: account.id, reference_id: other_account.id,
          amount: 1000 }
        let!(:inc_transaction) { create :transaction, :income, bank_account: account }
        let!(:exp_transaction) { create :transaction, :expense, bank_account: account }
        let!(:old_transaction) { create :transaction, :income, bank_account: account,
          date: Date.current - 2.years }
        let(:total) { org.bank_accounts.total_balance(account.currency) +
          org.bank_accounts.total_balance(other_account.currency) }

        subject { org.data_balance('years')[:data].last }

        it 'has contaion current month, income, expense and total amounts for all months' do
          expect(subject).to eq [Date.current.strftime("%Y"),
            inc_transaction.amount.to_f, exp_transaction.amount.abs.to_f, total.to_f]
        end
      end

      context 'current quarter' do
        let!(:transfer) { create :transfer, bank_account_id: account.id, reference_id: other_account.id,
          amount: 1000 }
        let!(:inc_transaction) { create :transaction, :income, bank_account: account }
        let!(:exp_transaction) { create :transaction, :expense, bank_account: account }
        let!(:old_transaction) { create :transaction, :income, bank_account: account,
          date: Date.current - 2.years }
        let(:total) { org.bank_accounts.total_balance(account.currency) +
          org.bank_accounts.total_balance(other_account.currency) }

        subject { org.data_balance('quarters')[:data].last }

        it 'has contaion current month, income, expense and total amounts for all months' do
          expect(subject).to eq [get_quarter(Date.current.strftime("%b, %Y")),
            inc_transaction.amount.to_f, exp_transaction.amount.abs.to_f, total.to_f]
        end
      end


      context 'has contaion previous month, income, expense and total amounts' do
        let!(:inc_transaction) { create :transaction, :income, bank_account: account,
          date: Date.current - 1.months }
        let!(:exp_transaction) { create :transaction, :expense, bank_account: account,
          date: Date.current - 1.months }
        let(:total) { inc_transaction.amount.to_f - exp_transaction.amount.abs.to_f }

        subject { org.data_balance[:data][12] }

        it 'has contaion previous month, income, expense and total amounts for all months' do
          expect(subject).to eq [(Date.current - 1.months).strftime("%b, %Y"),
            inc_transaction.amount.to_f, exp_transaction.amount.abs.to_f, total.round(2)]
        end
      end

      context 'has contaion previous year, income, expense and total amounts' do
        let!(:inc_transaction) { create :transaction, :income, bank_account: account,
          date: Date.current - 1.years }
        let!(:exp_transaction) { create :transaction, :expense, bank_account: account,
          date: Date.current - 1.years }
        let(:total) { inc_transaction.amount.to_f - exp_transaction.amount.abs.to_f }

        subject { org.data_balance('years')[:data][-2] }

        it 'has contaion previous year, income, expense and total amounts for all months' do
          expect(subject).to eq [(Date.current - 1.years).strftime("%Y"),
            inc_transaction.amount.to_f, exp_transaction.amount.abs.to_f, total.round(2)]
        end
      end

      context 'has contaion previous quarter, income, expense and total amounts' do
        let!(:inc_transaction) { create :transaction, :income, bank_account: account,
          date: Date.current - 3.months }
        let!(:exp_transaction) { create :transaction, :expense, bank_account: account,
          date: Date.current - 3.months }
        let(:total) { inc_transaction.amount.to_f - exp_transaction.amount.abs.to_f }

        subject { org.data_balance('quarters')[:data][-2] }

        it 'has contaion previous quarter, income, expense and total amounts for all months' do
          expect(subject).to eq [get_quarter((Date.current - 3.months).strftime("%b, %Y")),
            inc_transaction.amount.to_f, exp_transaction.amount.abs.to_f, total.round(2)]
        end
      end
    end
  end

  describe "#totals_by_customers" do
    let(:org) { create :organization, default_currency: 'USD' }

    context 'def currency' do
      let!(:customer) { create :customer }
      let!(:invoice)  { create :invoice, customer_name: customer.name,
        organization: org, ends_at: Date.current, currency: 'USD' }

      context 'current month' do
        let!(:invoice_item) { create :invoice_item, invoice: invoice,
          customer_name: customer.name, date: Date.current, amount: 500 }

        subject { org.totals_by_customers('current-month')[:data][1] }

        it 'is counted' do
          expect(subject).to eq [invoice_item.customer.name + ' ' +
            Money.new(invoice_item.amount, org.default_currency).format, invoice_item.amount.to_f]
        end
      end

      context 'previous month' do
        let!(:invoice_item) { create :invoice_item, invoice: invoice,
          customer_name: customer.name, date: Date.current - 1.months, amount: 500 }

        subject { org.totals_by_customers('current-month') }

        it 'is not counted' do
          expect(subject).to be_nil
        end
      end

      context 'without invoice item date' do
        let!(:invoice_item) { create :invoice_item, invoice: invoice,
          customer_name: customer.name, date: nil, amount: 500 }

        subject { org.totals_by_customers('current-month')[:data][1] }

        it 'is counted with invoice ends_at date' do
          expect(subject).to eq [invoice_item.customer.name + ' ' +
            Money.new(invoice_item.amount, org.default_currency).format, invoice_item.amount.to_f]
        end
      end

      context 'without invoice item date and invoice ends_at in previous month' do
        let!(:invoice_item) { create :invoice_item, invoice: invoice,
          customer_name: customer.name, date: nil, amount: 500 }

        before do
          invoice.update(ends_at: Date.current - 1.months)
        end

        subject { org.totals_by_customers('current-month') }

        it 'is not counted' do
          expect(subject).to be_nil
        end
      end

      context 'calculate with customer transactions' do
        let!(:invoice_item) { create :invoice_item, invoice: invoice,
          customer_name: customer.name, date: nil, amount: 500 }

        let(:account){ create :bank_account, organization: org, currency: 'USD',
          residue: 9999999 }
        let!(:transaction) { create :transaction, :with_customer, :income,
            bank_account: account }

        before do
          transaction.update(customer_name: invoice_item.customer_name)
        end

        subject { org.totals_by_customers('current-month')[:data][1] }

        it 'is counted with transaction amount' do
          expect(subject).to eq [invoice_item.customer.name + ' ' +
            Money.new(invoice_item.amount + transaction.amount, org.default_currency).format,
              invoice_item.amount.to_f + transaction.amount.to_f]
        end
      end
    end

  end

  describe "#by_customers(categories_type, :income)" do
    let(:org) { create :organization, default_currency: 'USD' }
    let!(:zero_transaction) do
      tr = build :transaction, :with_customer, :income, bank_account: account, amount: 0
      tr.save(validate: false)
      tr
    end

    context 'def currency' do
      let(:account){ create :bank_account, organization: org, currency: 'USD',
        residue: 9999999 }

      context 'income' do
        context 'current month' do
          let!(:transaction) { create :transaction, :with_customer, :income,
            bank_account: account }
          subject { org.by_customers(:incomes, 'current-month')[:data][1] }

          it 'is counted' do
            expect(subject).to eq [transaction.customer.name + ' ' +
              Money.new(transaction.amount, org.default_currency).format, transaction.amount.to_f]
          end
        end

        context 'previous month' do
          let!(:transaction) { Timecop.travel(1.month.ago) {
            create :transaction, :with_customer, :income, bank_account: account }
          }
          subject { org.by_customers(:incomes, 'current-month') }

          it 'is not counted' do
            expect(subject).to be_nil
          end
        end
      end

      context 'expense' do
        context 'current month' do
          let!(:transaction) { create :transaction, :with_customer, :expense,
            bank_account: account }
          subject { org.by_customers(:incomes, 'current-month') }

          it 'is not counted' do
            expect(subject).to be_nil
          end
        end

        context 'previous month' do
          let!(:transaction) { Timecop.travel(1.month.ago) {
            create :transaction, :with_customer, :expense, bank_account: account }
          }
          subject { org.by_customers(:incomes, 'current-month') }

          it 'is not counted' do
            expect(subject).to be_nil
          end
        end
      end
    end

    context 'aggr currency' do
      let(:account) { create :bank_account, organization: org, currency: 'USD',
        residue: 9999999 }
      let(:account2){ create :bank_account, organization: org, currency: 'RUB',
        residue: 9999999 }

      let(:customer) { create :customer, organization: org }
      let!(:transaction) { create :transaction, :income, customer: customer,
          bank_account: account }
      let!(:transaction2){ create :transaction, :income, customer: customer,
          bank_account: account2 }
      subject { org.by_customers(:incomes, 'current-month')[:data][1] }

      it 'is estimated correctly' do
        expect(subject).to eq [transaction.customer.name + ' ' +
          Money.new(transaction.amount + transaction2.amount.exchange_to('USD'), org.default_currency).format,
          (transaction.amount + transaction2.amount.exchange_to('USD')).to_f]
      end
    end
  end

  describe "#by_customers(categories_type, :expense)" do
    let(:org)    { create :organization, default_currency: 'USD' }
    let!(:zero_transaction) do
      tr = build :transaction, :with_customer, :income, bank_account: account, amount: 0
      tr.save(validate: false)
      tr
    end

    context 'def currency' do
      let(:account){ create :bank_account, organization: org, currency: 'USD',
        residue: 9999999 }

      context 'income' do
        context 'current month' do
          let!(:transaction) { create :transaction, :with_customer, :income,
            bank_account: account }
          subject { org.by_customers(:expenses, 'current-month') }

          it 'is not counted' do
            expect(subject).to be_nil
          end
        end

        context 'previous month' do
          let!(:transaction) { Timecop.travel(1.month.ago) {
            create :transaction, :with_customer, :income, bank_account: account }
          }
          subject { org.by_customers(:expenses, 'current-month') }

          it 'is not counted' do
            expect(subject).to be_nil
          end
        end
      end

      context 'expense' do
        context 'current month' do
          let!(:transaction) { create :transaction, :with_customer, :expense,
            bank_account: account }
          subject { org.by_customers(:expenses, 'current-month')[:data][1] }

          it 'is not counted' do
            expect(subject).to eq [transaction.customer.name + ' ' +
              Money.new(transaction.amount.abs, org.default_currency).format, transaction.amount.to_f.abs]
          end
        end

        context 'previous month' do
          let!(:transaction) { Timecop.travel(1.month.ago) {
            create :transaction, :with_customer, :expense, bank_account: account }
          }
          subject { org.by_customers(:expenses, 'current-month') }

          it 'is not counted' do
            expect(subject).to be_nil
          end
        end
      end
    end

    context 'aggr currency' do
      let(:account) { create :bank_account, organization: org, currency: 'USD',
        residue: 9999999 }
      let(:account2){ create :bank_account, organization: org, currency: 'RUB',
        residue: 9999999 }

      let(:customer) { create :customer, organization: org }
      let!(:transaction) { create :transaction, :expense, customer: customer,
          bank_account: account }
      let!(:transaction2){ create :transaction, :expense, customer: customer,
          bank_account: account2 }
      subject { org.by_customers(:expenses, 'current_month')[:data][1] }

      it 'is estimated correctly' do
        expect(subject).to eq [transaction.customer.name + ' ' +
          Money.new((transaction.amount + transaction2.amount.exchange_to('USD')).abs, org.default_currency).format,
          (transaction.amount + transaction2.amount.exchange_to('USD')).to_f.abs]
      end
    end
  end

  describe "#by_categories(categories_type, :income)" do
    let(:org) { create :organization, default_currency: 'USD' }
    let!(:zero_transaction) do
      tr = build :transaction, :with_customer, :income, bank_account: account, amount: 0
      tr.save(validate: false)
      tr
    end

    context 'def currency' do
      let(:account){ create :bank_account, organization: org, currency: 'USD',
        residue: 9999999 }

      context 'income' do
        context 'current month' do
          let!(:transaction) { create :transaction, :income, bank_account: account }
          subject { org.by_categories(:incomes, 'current-month')[:data][1] }

          it 'is counted' do
            expect(subject).to eq [transaction.category.name + ' ' +
              Money.new(transaction.amount, org.default_currency).format, transaction.amount.to_f]
          end
        end

        context 'previous month' do
          let!(:transaction) { Timecop.travel(1.month.ago) {
            create :transaction, :income, bank_account: account }
          }
          subject { org.by_categories(:incomes, 'current-month') }

          it 'is not counted' do
            expect(subject).to be_nil
          end
        end
      end

      context 'expense' do
        context 'current month' do
          let!(:transaction) { create :transaction, :expense, bank_account: account }
          subject { org.by_categories(:incomes, 'current-month') }

          it 'is not counted' do
            expect(subject).to be_nil
          end
        end

        context 'previous month' do
          let!(:transaction) { Timecop.travel(1.month.ago) {
            create :transaction, :expense, bank_account: account }
          }
          subject { org.by_categories(:incomes, 'current-month') }

          it 'is not counted' do
            expect(subject).to be_nil
          end
        end
      end
    end

    context 'aggr currency' do
      let(:account) { create :bank_account, organization: org, currency: 'USD',
        residue: 9999999 }
      let(:account2){ create :bank_account, organization: org, currency: 'RUB',
        residue: 9999999 }

      let(:category) { create :category, organization: org }
      let!(:transaction) { create :transaction, :income, category: category,
          bank_account: account }
      let!(:transaction2){ create :transaction, :income, category: category,
          bank_account: account2 }
      subject { org.by_categories(:incomes, 'current-month')[:data][1] }

      it 'is estimated correctly' do
        expect(subject).to eq [transaction.category.name + ' ' +
          Money.new(transaction.amount + transaction2.amount.exchange_to('USD'), org.default_currency).format,
          (transaction.amount + transaction2.amount.exchange_to('USD')).to_f]
      end
    end
  end

  describe "#by_categories(categories_type, :expense)" do
    let(:org)    { create :organization, default_currency: 'USD' }
    let!(:zero_transaction) do
      tr = build :transaction, :with_customer, :income, bank_account: account, amount: 0
      tr.save(validate: false)
      tr
    end

    context 'def currency' do
      let(:account){ create :bank_account, organization: org, currency: 'USD',
        residue: 9999999 }

      context 'income' do
        context 'current month' do
          let!(:transaction) { create :transaction, :income, bank_account: account }
          subject { org.by_categories(:expenses, 'current-month') }

          it 'is not counted' do
            expect(subject).to be_nil
          end
        end

        context 'previous month' do
          let!(:transaction) { Timecop.travel(1.month.ago) {
            create :transaction, :income, bank_account: account }
          }
          subject { org.by_categories(:expenses, 'current-month') }

          it 'is not counted' do
            expect(subject).to be_nil
          end
        end
      end

      context 'expense' do
        context 'current month' do
          let!(:transaction) { create :transaction, :expense, bank_account: account }
          subject { org.by_categories(:expenses, 'current-month')[:data][1] }

          it 'is not counted' do
            expect(subject).to eq [transaction.category.name + ' ' +
              Money.new(transaction.amount.abs, org.default_currency).format, transaction.amount.to_f.abs]
          end
        end

        context 'previous month' do
          let!(:transaction) { Timecop.travel(1.month.ago) {
            create :transaction, :expense, bank_account: account }
          }
          subject { org.by_categories(:expenses, 'current-month') }

          it 'is not counted' do
            expect(subject).to be_nil
          end
        end
      end
    end

    context 'aggr currency' do
      let(:account) { create :bank_account, organization: org, currency: 'USD',
        residue: 9999999 }
      let(:account2){ create :bank_account, organization: org, currency: 'RUB',
        residue: 9999999 }

      let(:category) { create :category, :expense, organization: org }
      let!(:transaction) { create :transaction, :expense, category: category,
          bank_account: account }
      let!(:transaction2){ create :transaction, :expense, category: category,
          bank_account: account2 }
      subject { org.by_categories(:expenses, 'current_month')[:data][1] }

      it 'is estimated correctly' do
        expect(subject).to eq [transaction.category.name + ' ' +
          Money.new((transaction.amount + transaction2.amount.exchange_to('USD')).abs, org.default_currency).format,
          (transaction.amount + transaction2.amount.exchange_to('USD')).to_f.abs]
      end
    end
  end

  describe "#customers_by_months" do
    let!(:org) { create :organization, default_currency: 'RUB' }
    let!(:customer1) { create :customer, organization: org }
    let!(:customer2) { create :customer, organization: org }
    let!(:category) { create :category, :income, organization: org }
    let!(:transaction1) do
      create :transaction, :income, organization: org,
        customer: customer1, category: category
    end
    let!(:transaction2) do
      create :transaction, :income, organization: org,
        customer: customer2, category: category
    end

    context 'current month' do
      subject { org.customers_by_months[:data].last }

      it 'have data about transactions in current month' do
        expect(subject).to eq([Date.current.strftime("%b, %Y"),
         (transaction1.amount.cents/100).round(2),
         (transaction2.amount.cents/100).round(2), ""])
      end
    end

    context 'previous month' do
      let!(:transaction3) do
        create :transaction, :income, organization: org,
          customer: customer1, category: category,
          date: DateTime.now - 1.months
      end
      let!(:transaction4) do
        create :transaction, :income, organization: org,
          customer: customer2, category: category,
          date: DateTime.now - 1.months
      end
      subject { org.customers_by_months[:data][-2] }

      it 'have data about transactions in previous month' do
        expect(subject).to eq([(Date.current - 1.months).strftime("%b, %Y"),
         (transaction3.amount.cents/100).round(2),
         (transaction4.amount.cents/100).round(2), ""])
      end
    end

    context 'organization have transaction with different currency' do
      let!(:account) { create :bank_account, organization: org, currency: 'USD'}
      let!(:customer3) { create :customer, organization: org }
      let!(:transaction3) do
        create :transaction, :income, organization: org,
          customer: customer3, category: category, bank_account: account
      end

      subject { org.customers_by_months[:data].last }

      it 'convert amounts to organization currency' do
        expect(subject).to eq([Date.current.strftime("%b, %Y"),
         (transaction1.amount.cents/100).round(2),
         (transaction2.amount.cents/100).round(2),
         (transaction3.amount.exchange_to('RUB').cents/100).round(2),""])
      end
    end

    context 'transaction without customer' do
      let!(:transaction3) do
        create :transaction, :income, organization: org,
          customer: nil, category: category
      end

      subject { org.customers_by_months[:data].last }

      it 'have data about transactions in current month' do
        expect(subject).to eq([Date.current.strftime("%b, %Y"),
         (transaction1.amount.cents/100).round(2),
         (transaction2.amount.cents/100).round(2), ""])
      end
    end
  end
end
