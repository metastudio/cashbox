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
#

require 'spec_helper'

describe Transaction do
  context "association" do
    it { should belong_to(:category) }
    it { should belong_to(:bank_account)  }
    it { should have_one(:organization).through(:bank_account) }
  end

  context "validation" do
    it { should validate_presence_of(:category)     }
    it { should validate_presence_of(:bank_account) }

    context "custom" do
      context 'when expense' do
        let(:account) { create :bank_account }

        subject { transaction }

        context 'when not enough money' do
          let(:transaction) { build :transaction, :expense, bank_account: account }

          it 'is invalid' do
            expect(subject).to be_invalid
            expect(subject.errors_on(:amount)).
              to include("Not enough money")
          end
        end

        describe 'on update' do
          context 'compare amount to bank_account-amount_was' do
            let!(:transaction) { create :transaction, bank_account: account }
            let!(:category)    { create :category, :expense }

            before { transaction.category = category }

            it 'is invalid' do
              expect(subject).to be_invalid
              expect(subject.errors_on(:amount)).
                to include("Not enough money")
            end
          end
        end
      end

      context "amount value" do
        it_behaves_like "has money ceiling", "amount" do
          let(:max)    { Transaction::AMOUNT_MAX }
          let!(:model) { build :transaction, amount: amount }
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
        let(:start_amount) { 1234.56 }
        let(:finish_amount) { 5345.34 }
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
            expect(subject).to be_true
          end
        end

        context "and negative amount" do
          let(:amount) { -123.32 }

          it 'is invalid' do
            expect(transaction).to be_invalid
            expect(transaction.errors_on(:amount)).
              to include("must be greater than 0")
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
            expect(subject).to be_true
          end
        end

        context "and negative amount" do
          let(:amount) { -123.32 }

          it 'is invalid' do
            expect(transaction).to be_invalid
            expect(transaction.errors_on(:amount)).
              to include("must be greater than 0")
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
end
