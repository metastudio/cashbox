shared_examples_for 'chart countable' do |category_right, category_wrong|
  subject { org.by_customers(category_right.to_s.pluralize, period) }

  context 'def currency' do
    context 'current month' do
      let(:period) { "current-month" }
      context category_right do
        let!(:right_t)  { create :transaction, :with_customer, category_right,
          bank_account: account }
        let!(:wrong_t)  { Timecop.travel(1.month.ago) {
          create :transaction, :with_customer, category_right, bank_account: account }
        }

        it 'counted' do
          expect(subject[:data][1]).
            to include(right_t.customer.name, right_t.amount.to_f)
        end
      end

      context category_wrong do
        let!(:wrong_t) { create :transaction, :with_customer, category_wrong,
          bank_account: account }

        it 'not counted' do
          expect(subject).to be_nil
        end
      end
    end

    context 'prev month' do
      let(:period) { "previous month" }
      context category_right do
        let!(:wrong_t)   { create :transaction, :with_customer, category_right,
          bank_account: account }
        let!(:right_t) { Timecop.travel(1.month.ago) {
          create :transaction, :with_customer, category_right, bank_account: account }
        }

        it 'counted' do
          expect(subject[:data][1]).
            to include(right_t.customer.name, right_t.amount.to_f)
        end
      end

      context category_wrong do
        let!(:wrong_t) { Timecop.travel(1.month.ago) {
          create :transaction, :with_customer, category_wrong, bank_account: account }
        }

        it 'not counted' do
          expect(subject).to be_nil
        end
      end
    end

    context 'current-quarter' do
      let(:period) { "current-quarter" }
      context category_right do
        let!(:right_t)  { create :transaction, :with_customer, category_right,
          bank_account: account }
        let!(:wrong_t) { Timecop.travel(Time.now.beginning_of_quarter - 1.month) {
          create :transaction, :with_customer, category_right, bank_account: account }
        }

        it 'counted' do
          expect(subject[:data][1]).
            to include(right_t.customer.name, right_t.amount.to_f)
        end
      end

      context category_wrong do
        let!(:wrong_t)  { create :transaction, :with_customer, category_wrong,
          bank_account: account }

        it 'not counted' do
          expect(subject).to be_nil
        end
      end
    end

    context 'this year' do
      let(:period) { "this-year" }
      context category_right do
        let!(:right_t) { create :transaction, :with_customer, category_right,
          bank_account: account, amount: 10000 }
        let!(:wrong_t) { Timecop.travel(1.year.ago + 1.month) {
          create :transaction, :with_customer, category_right, bank_account: account }
        }

        it 'counted' do
          expect(subject[:data][1]).
            to include(right_t.customer.name, right_t.amount.to_f)
        end
      end

      context category_wrong do
        let!(:wrong_t) { create :transaction, :with_customer, category_wrong,
          bank_account: account }

        it 'not counted' do
          expect(subject).to be_nil
        end
      end
    end

    context 'all time' do
      let(:period) { "all-time" }
      let!(:right_t) { create :transaction, :with_customer, category_right,
        bank_account: account }
      let!(:right_t2) { Timecop.travel(1.year.ago) {
        create :transaction, category_right, customer: right_t.customer,
        bank_account: account }
      }

      it 'counted' do
        expect(subject[:data][1]).
          to include(right_t.customer.name, (right_t.amount + right_t2.amount).to_f)
      end
    end
  end

  context 'aggr currency' do
    let(:account) { create :bank_account, organization: org, currency: 'USD',
      residue: 9999999 }
    let(:account2){ create :bank_account, organization: org, currency: 'RUB',
      residue: 9999999 }

    let(:customer) { create :customer, organization: org }
    let!(:transaction) { create :transaction, category_right, customer: customer,
        bank_account: account }
    let!(:transaction2){ create :transaction, category_right, customer: customer,
        bank_account: account2 }

    let(:period) { :nil }

    it 'is estimated correctly' do
      expect(subject[:data][1]).
        to eq [transaction.customer.name,
          (transaction.amount + transaction2.amount.exchange_to('USD')).to_f]
    end
  end
end
