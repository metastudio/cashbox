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
  end

  context "callback" do
    describe "#recalculate_amount" do
      let(:account) { create :bank_account }

      subject{ transaction.save }

      context "for creation" do
        context "income transaction" do
          let(:transaction)  { build :transaction, :income, bank_account: account }

          it "adds transaction amount to account's balance" do
            expect{ subject }.to change(account, :balance_cents).by(transaction.amount_cents)
          end
        end

        context "expense transaction" do
          let(:transaction)  { build :transaction, :expense, bank_account: account }

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

          it "changes amount to positive" do
            expect{ subject }.to change{ transaction.amount.to_f }.to(amount.abs)
          end

          it "doesn't break saving" do
            expect(subject).to be_true
          end
        end
      end

      context "for expense category" do
        let(:transaction) { build :transaction, :expense, amount: amount }

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

          it "stays amount negative" do
            expect{ subject }.to_not change(transaction, :amount)
          end

          it "doesn't break saving" do
            expect(subject).to be_true
          end
        end
      end
    end
  end
end
