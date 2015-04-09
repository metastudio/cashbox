require 'spec_helper'
require 'transfer'

describe Transfer do
  subject { Transfer.new }

  context "validation" do
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:bank_account_id) }
    it { should validate_length_of(:comment).is_at_most(255) }
    it { should validate_presence_of(:reference_id) }
    it { should validate_numericality_of(:comission).
      is_greater_than_or_equal_to(0) }
    it { should validate_length_of(:comission).is_at_most(10) }
    it { should validate_presence_of(:reference_id) }

    context "custom validations" do

      subject { transfer }

      context 'when depends on bank account' do
        let(:transfer) { build :transfer, bank_account_id: from.id, reference_id: to.id }

        describe "transfer_amount" do
          let(:from) { create :bank_account, balance: 100 }
          let(:to)   { create :bank_account, balance: 200 }

          it 'is invalid' do
            expect(subject).to be_invalid
            expect(subject.errors_on(:amount)).
              to include("Not enough money")
          end
        end

        describe 'balance overflow' do
          let(:from) { create :bank_account, balance: 10000 }
          let(:to)   { create :bank_account, :full }

          before do
            transfer.save
          end

          it 'is invalid' do
            expect(transfer.save).to eq false
          end

          it 'has error on amount' do
            expect(transfer.errors.messages[:amount]).to include("Balance overflow")
          end
        end

        context "transfer_account" do
          let(:from) { create :bank_account, balance: 100 }
          let(:to)   { from }

          it 'is invalid' do
            expect(subject).to be_invalid
            expect(subject.errors_on(:reference_id)).
              to include("Can't transfer to same account")
          end
        end

        context "diff currency" do
          let(:from) { create :bank_account, currency: "USD", balance: 9999999 }
          let(:to)   { create :bank_account, currency: "RUB", balance: 9999999 }

          describe 'exchange_rate' do
            let(:transfer) { build :transfer, exchange_rate: 10_001,
              bank_account_id: from.id, reference_id: to.id,
              from_currency: from.currency, to_currency: to.currency }

            it "is invalid" do
              expect(subject).to be_invalid
              expect(subject.errors_on(:exchange_rate)).
                to include("must be less than 10000")
            end
          end
        end
      end
    end
  end

  describe "#save" do
    let(:transfer) { build :transfer }

    subject { transfer.save }

    context 'with valid data' do
      context "create 2 transactions" do
        it { expect{subject}.to change{Transaction.count}.by(2) }

        describe 'attributes' do
          let(:inc) { transfer.inc_transaction }
          let(:out) { transfer.out_transaction }

          before do
            transfer.save
          end

          describe 'same currency' do
            let(:amount) { transfer.amount_cents }

            it_behaves_like 'income transaction'
            it_behaves_like 'outcome transaction'
          end

          describe 'with different currencies' do
            let(:transfer) { build :transfer, :with_different_currencies,
              exchange_rate: 2, amount: 111 }

            it_behaves_like 'income transaction' do
              let(:amount) { transfer.exchange_rate * transfer.amount_cents }
            end
            it_behaves_like 'outcome transaction' do
              let(:amount) { transfer.amount_cents }
            end
          end
        end
      end
    end

    context 'with invalid data' do
      let(:from) { create :bank_account, balance: 2000 }
      let(:to)   { create :bank_account, balance: Dictionaries.money_max }
      let(:transfer) { build :transfer, bank_account_id: from.id, reference_id: to.id }

      context "doesn't create transactions" do
        it { expect{subject}.to change{Transaction.count}.by(0) }
      end

      context "add errors on transaction" do
        context "when transfer params wrong" do
          let(:transfer) { build :transfer, bank_account_id: from.id, reference_id: to.id,
            amount: from.balance + Money.new(100, from.currency) }

          before do
            transfer.save
          end

          it { expect(transfer.errors.messages[:amount]).to include("Not enough money") }
        end
      end
    end
  end
end
