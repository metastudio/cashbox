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
#  date             :datetime         not null
#  transfer_out_id  :integer
#  invoice_id       :integer
#  created_by_id    :integer
#

require 'rails_helper'

describe Transaction do
  context "association" do
    it { should belong_to(:category) }
    it { should belong_to(:bank_account).touch(true)  }
    it { expect(subject).to belong_to(:customer) }
    it { should have_one(:organization).through(:bank_account) }
    it { should belong_to(:created_by) }
  end

  context "validation" do
    it { should validate_presence_of(:category)     }
    it { should validate_presence_of(:bank_account) }
    it { should validate_numericality_of(:amount).is_less_than_or_equal_to(Dictionaries.money_max) }

    context "custom" do
      subject { transaction }

      context 'amount value' do
        it_behaves_like 'has money ceiling', 'amount' do
          let!(:model) { build :transaction, amount: amount }
        end
      end

      context 'when has commission' do
        let(:account) { create :bank_account, currency: 'RUB' }
        let(:invoice) { create :invoice }
        let!(:transaction) { build :transaction, :income, bank_account: account,
          invoice: invoice, amount: 100, comission: 200 }

        it 'is invalid' do
          expect(subject).to be_invalid
          expect(subject.errors_on(:comission)).to include("Can't be more than amount")
        end
      end

      context 'when balance overflow' do
        let(:account)      { create :bank_account, :full }
        let!(:transaction) { build :transaction, :income, bank_account: account,
          amount: 100 }

        it 'is invalid' do
          expect(subject).to be_invalid
          expect(subject.errors_on(:amount)).
            to include("Balance overflow")
        end
      end

      context 'numericaly other_than' do
        let(:account)      { create :bank_account, :full }
        let!(:transaction) { build :transaction, :income, bank_account: account,
          amount: 0 }

        it 'is invalid' do
          expect(subject).to be_invalid
          expect(subject.errors_on(:amount)).
            to include("must be other than 0")
        end
      end
    end
  end

  context "callback" do
    describe "#recalculate_amount" do
      let(:account) { create :bank_account, :with_transactions }

      subject{ transaction.save }

      context "for creation" do
        context "income transaction" do
          let(:transaction)  { build :transaction, :income, bank_account: account }

          it "adds transaction amount to account's balance" do
            expect{ subject }.to change(account, :balance_cents).by(transaction.amount_cents)
          end
        end

        context "expense transaction" do
          let(:transaction)  { build :transaction, :expense, bank_account: account,
          amount: 500 }

          it "subtracts transaction amount from account's balance" do
            expect{ subject }.to change(account, :balance_cents).by(-transaction.amount_cents)
          end
        end

        context "transaction with invalid data" do
          let(:transaction) { build :transaction, :income, bank_account: account, category: nil }

          it "doesn't change account's balance" do
            expect{ subject }.to_not change(account, :balance_cents)
          end
        end
      end

      context "for updating transaction (without amount change)" do
        let!(:transaction) { create :transaction, :income, bank_account: account }

        subject{ transaction.update_attributes(comment: 'test comment') }

        it "doesn't change account's balance" do
          expect{ subject }.to_not change(account, :balance_cents)
        end
      end

      context "for changing amount of transaction" do
        let(:start_amount)  { 1234.56 }
        let(:finish_amount) { 5345.30 }
        let!(:transaction) { create :transaction, :income, bank_account: account, amount: start_amount }

        subject{ transaction.update_attributes(amount: finish_amount) }

        it "changes account's balance by difference of updated amount" do
          expect{ subject }.to change(account, :balance_cents).by((finish_amount - start_amount) * 100)
        end
      end

      context "for remove transaction" do
        let!(:transaction) { create :transaction, :income, bank_account: account }

        subject{ transaction.destroy }

        it "substracts amount from account's balance" do
          expect{ subject }.to change(account, :balance_cents).by(-transaction.amount_cents)
        end
      end
    end

    describe "#check_negative" do
      subject{ transaction.save }

      context "for income category" do
        let(:transaction) { build :transaction, :income, amount: amount }

        context "and positive amount" do
          let(:amount) { 123.32 }

          it "stays amount positive" do
            expect{ subject }.to_not change(transaction, :amount)
          end

          it "doesn't break saving" do
            expect(subject).to be_truthy
          end
        end
      end

      context "for expense category" do
        let(:account)  { create :bank_account, :with_transactions }
        let(:transaction) { build :transaction, :expense, bank_account: account,
          amount: amount }

        context "and positive amount" do
          let(:amount) { 123.32 }

          it "change amount to negative if category is expense" do
            expect{ subject }.to change{ transaction.amount.to_f }.to(-amount)
          end

          it "doesn't break saving" do
            expect(subject).to be_truthy
          end
        end

        context "and negative amount" do
          let(:amount) { -123.32 }

          it 'is valid' do
            expect(transaction).to be_valid
          end
        end
      end
    end
  end

  describe 'soft delete' do
    let(:bank_account)  { create :bank_account }
    let(:amount)        { Money.new(100, bank_account.currency) }
    let!(:transaction)  { create :transaction, bank_account: bank_account,
      amount: amount }

    describe "transaction destroy" do
      it "changes balance" do
        expect{transaction.destroy}.to change{bank_account.balance}.by(-amount)
      end

      context "then restore" do
        before do
          transaction.destroy
        end

        it "changes balance" do
          expect{transaction.restore}.to change{bank_account.balance}.by(amount)
        end
      end
    end
  end

  describe '#flow_ordered(def_curr)' do
    let(:org)        { create :organization }
    let(:def_curr)   { "USD" }
    let(:slave_curr) { "RUB" }
    let(:slave_acc)  { create :bank_account, organization: org, currency: slave_curr }
    let(:def_acc)    { create :bank_account, organization: org, currency: def_curr }
    let!(:slave_list) { create_list :transaction, 5, bank_account: slave_acc }
    let!(:def_list)   { create_list :transaction, 5, bank_account: def_acc }
    let(:slave_trans) { org.transactions.by_currency(slave_curr) }
    let(:def_trans)   { org.transactions.by_currency(def_curr) }

    let(:slave_inc) { Money.new(slave_trans.incomes.sum(:amount_cents), slave_curr)}
    let(:slave_exp) { Money.new(slave_trans.expenses.sum(:amount_cents), slave_curr)}
    let(:def_inc) { Money.new(def_trans.incomes.sum(:amount_cents), def_curr)}
    let(:def_exp) { Money.new(def_trans.expenses.sum(:amount_cents), def_curr)}

    subject { org.transactions.flow_ordered(org.default_currency) }

    it "return ordered array of summed income, expense, currency for each currency" do
      expect(subject).to eq [
        Transaction::AmountFlow.new(def_inc, def_exp, def_curr),
        Transaction::AmountFlow.new(slave_inc, slave_exp, slave_curr)]
    end
  end

  describe '#send_notification' do
    ActiveJob::Base.queue_adapter = :test
    before { ActiveJob::Base.queue_adapter.enqueued_jobs = [] }
    let!(:transaction) { create :transaction }

    it 'send notification after creation' do
      expect(NotificationJob).to have_been_enqueued.with(
        transaction.organization.name,
        "Transaction was added",
        "Transaction was added to organization #{transaction.organization.name}"
      )
    end
  end
end
