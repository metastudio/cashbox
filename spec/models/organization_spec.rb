# == Schema Information
#
# Table name: organizations
#
#  id               :integer          not null, primary key
#  name             :string           not null
#  created_at       :datetime
#  updated_at       :datetime
#  default_currency :string           default("USD")
#

require 'spec_helper'

describe Organization do
  context 'assocation' do
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
      Dictionaries.currencies << 'EUR' unless Dictionaries.currencies.include?('EUR')
    end

    after do
      Dictionaries.currencies.delete('EUR') if Dictionaries.currencies.include?('EUR')
    end

    context 'with updated Dictionary for including EUR' do
      let!(:org) { create :organization }
      let!(:ba)  { create :bank_account, currency: 'USD', organization: org }
      let!(:ba2) { create :bank_account, currency: 'RUB', organization: org }
      let!(:ba3) { create :bank_account, currency: 'EUR', organization: org }

      # ToDo needs to be updated when we change default bank
      # should contain then each-to-each currency keys e.x. USD_TO_EUR
      # not only within RUB
      it 'return only present currency rates' do
        expect(org.exchange_rates.keys).to eq ['RUB_TO_USD', 'USD_TO_RUB', 'RUB_TO_EUR', 'EUR_TO_RUB']
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

  describe "#by_customers(categories_type, :income)" do
    let(:org) { create :organization, default_currency: 'USD' }

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

end
