require 'rails_helper'

describe StatisticData::RoundChart do
  let(:org) { create :organization, default_currency: 'USD' }
  let(:account){ create :bank_account, organization: org, currency: 'USD',
        residue: 9999999 }

  describe '#by_categories(categories_type, :income)' do
    context 'income' do
      context 'current month' do
        let!(:transaction) { create :transaction, :income, bank_account: account }
        subject { StatisticData::RoundChart.new(org).by_categories(:incomes, 'current-month')[:data][1] }

        it 'is counted' do
          expect(subject).to eq [transaction.category.name + ' ' +
            Money.new(transaction.amount, org.default_currency).format, transaction.amount.to_f]
        end
      end

      context 'previous month' do
        let!(:transaction) { Timecop.travel(1.month.ago) {
          create :transaction, :income, bank_account: account }
        }
        subject { StatisticData::RoundChart.new(org).by_categories(:incomes, 'current-month') }

        it 'is not counted' do
          expect(subject).to be_nil
        end
      end
    end

    context 'expense' do
      context 'current month' do
        let!(:transaction) { create :transaction, :expense, bank_account: account }
        subject { StatisticData::RoundChart.new(org).by_categories(:incomes, 'current-month') }

        it 'is not counted' do
          expect(subject).to be_nil
        end
      end

      context 'previous month' do
        let!(:transaction) { Timecop.travel(1.month.ago) {
          create :transaction, :expense, bank_account: account }
        }
        subject { StatisticData::RoundChart.new(org).by_categories(:incomes, 'current-month') }

        it 'is not counted' do
          expect(subject).to be_nil
        end
      end
    end
  end

  describe "#by_categories(categories_type, :expense)" do
    context 'def currency' do
      let(:account){ create :bank_account, organization: org, currency: 'USD',
        residue: 9999999 }

      context 'income' do
        context 'current month' do
          let!(:transaction) { create :transaction, :income, bank_account: account }
          subject { StatisticData::RoundChart.new(org).by_categories(:expenses, 'current-month') }

          it 'is not counted' do
            expect(subject).to be_nil
          end
        end

        context 'previous month' do
          let!(:transaction) { Timecop.travel(1.month.ago) {
            create :transaction, :income, bank_account: account }
          }
          subject { StatisticData::RoundChart.new(org).by_categories(:expenses, 'current-month') }

          it 'is not counted' do
            expect(subject).to be_nil
          end
        end
      end

      context 'expense' do
        context 'current month' do
          let!(:transaction) { create :transaction, :expense, bank_account: account }
          subject { StatisticData::RoundChart.new(org).by_categories(:expenses, 'current-month')[:data][1] }

          it 'is not counted' do
            expect(subject).to eq [transaction.category.name + ' ' +
              Money.new(transaction.amount.abs, org.default_currency).format, transaction.amount.to_f.abs]
          end
        end

        context 'previous month' do
          let!(:transaction) { Timecop.travel(1.month.ago) {
            create :transaction, :expense, bank_account: account }
          }
          subject { StatisticData::RoundChart.new(org).by_categories(:expenses, 'current-month') }

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
      subject { StatisticData::RoundChart.new(org).by_categories(:expenses, 'current_month')[:data][1] }

      it 'is estimated correctly' do
        expect(subject).to eq [transaction.category.name + ' ' +
          Money.new((transaction.amount + transaction2.amount.exchange_to('USD')).abs, org.default_currency).format,
          (transaction.amount + transaction2.amount.exchange_to('USD')).to_f.abs]
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
          subject { StatisticData::RoundChart.new(org).by_customers(:incomes, 'current-month')[:data][1] }

          it 'is counted' do
            expect(subject).to eq [transaction.customer.name + ' ' +
              Money.new(transaction.amount, org.default_currency).format, transaction.amount.to_f]
          end
        end

        context 'previous month' do
          let!(:transaction) { Timecop.travel(1.month.ago) {
            create :transaction, :with_customer, :income, bank_account: account }
          }
          subject { StatisticData::RoundChart.new(org).by_customers(:incomes, 'current-month') }

          it 'is not counted' do
            expect(subject).to be_nil
          end
        end
      end

      context 'expense' do
        context 'current month' do
          let!(:transaction) { create :transaction, :with_customer, :expense,
            bank_account: account }
          subject { StatisticData::RoundChart.new(org).by_customers(:incomes, 'current-month') }

          it 'is not counted' do
            expect(subject).to be_nil
          end
        end

        context 'previous month' do
          let!(:transaction) { Timecop.travel(1.month.ago) {
            create :transaction, :with_customer, :expense, bank_account: account }
          }
          subject { StatisticData::RoundChart.new(org).by_customers(:incomes, 'current-month') }

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
      subject { StatisticData::RoundChart.new(org).by_customers(:incomes, 'current-month')[:data][1] }

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
          subject { StatisticData::RoundChart.new(org).by_customers(:expenses, 'current-month') }

          it 'is not counted' do
            expect(subject).to be_nil
          end
        end

        context 'previous month' do
          let!(:transaction) { Timecop.travel(1.month.ago) {
            create :transaction, :with_customer, :income, bank_account: account }
          }
          subject { StatisticData::RoundChart.new(org).by_customers(:expenses, 'current-month') }

          it 'is not counted' do
            expect(subject).to be_nil
          end
        end
      end

      context 'expense' do
        context 'current month' do
          let!(:transaction) { create :transaction, :with_customer, :expense,
            bank_account: account }
          subject { StatisticData::RoundChart.new(org).by_customers(:expenses, 'current-month')[:data][1] }

          it 'is not counted' do
            expect(subject).to eq [transaction.customer.name + ' ' +
              Money.new(transaction.amount.abs, org.default_currency).format, transaction.amount.to_f.abs]
          end
        end

        context 'previous month' do
          let!(:transaction) { Timecop.travel(1.month.ago) {
            create :transaction, :with_customer, :expense, bank_account: account }
          }
          subject { StatisticData::RoundChart.new(org).by_customers(:expenses, 'current-month') }

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
      subject { StatisticData::RoundChart.new(org).by_customers(:expenses, 'current_month')[:data][1] }

      it 'is estimated correctly' do
        expect(subject).to eq [transaction.customer.name + ' ' +
          Money.new((transaction.amount + transaction2.amount.exchange_to('USD')).abs, org.default_currency).format,
          (transaction.amount + transaction2.amount.exchange_to('USD')).to_f.abs]
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

        subject { StatisticData::RoundChart.new(org).totals_by_customers('current-month')[:data][1] }

        it 'is counted' do
          expect(subject).to eq [invoice_item.customer.name + ' ' +
            Money.new(invoice_item.amount, org.default_currency).format, invoice_item.amount.to_f]
        end
      end

      context 'previous month' do
        let!(:invoice_item) { create :invoice_item, invoice: invoice,
          customer_name: customer.name, date: Date.current - 1.months, amount: 500 }

        subject { StatisticData::RoundChart.new(org).totals_by_customers('current-month') }

        it 'is not counted' do
          expect(subject).to be_nil
        end
      end

      context 'without invoice item date' do
        let!(:invoice_item) { create :invoice_item, invoice: invoice,
          customer_name: customer.name, date: nil, amount: 500 }

        subject { StatisticData::RoundChart.new(org).totals_by_customers('current-month')[:data][1] }

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

        subject { StatisticData::RoundChart.new(org).totals_by_customers('current-month') }

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

        subject { StatisticData::RoundChart.new(org).totals_by_customers('current-month')[:data][1] }

        it 'is counted with transaction amount' do
          expect(subject).to eq [invoice_item.customer.name + ' ' +
            Money.new(invoice_item.amount + transaction.amount, org.default_currency).format,
              invoice_item.amount.to_f + transaction.amount.to_f]
        end
      end
    end

  end
end
