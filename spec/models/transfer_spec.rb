require 'spec_helper'
require 'transfer'

describe Transfer do
  subject { Transfer.new }

  context "validation" do
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }
    it { should ensure_length_of(:amount).is_at_most(20) }
    it { should validate_presence_of(:bank_account_id) }
    it { should ensure_length_of(:comment).is_at_most(255) }
    it { should validate_presence_of(:reference_id) }
    it { should validate_numericality_of(:comission).
      is_greater_than_or_equal_to(0) }
    it { should ensure_length_of(:comission).is_at_most(10) }

    context "custom validations" do
      let(:bank_account1) { create :bank_account, balance: 100 }
      let(:bank_account2) { create :bank_account, balance: 200 }
      let(:reference_id ) { bank_account2.id }
      let(:transfer)      { build :transfer, bank_account_id: bank_account1.id,
        reference_id: reference_id }

      subject { transfer }
      describe "transfer_amount" do
        it 'is invalid' do
          expect(subject).to be_invalid
          expect(subject.errors_on(:amount)).
            to include("Not enough money")
        end
      end

      context "same currency" do
        it { should validate_presence_of(:reference_id) }
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
            it_behaves_like 'income transaction' do
              let(:amount) { transfer.amount_cents }
            end
            it_behaves_like 'outcome transaction'
          end

          describe 'with different currencies' do
            let(:transfer) { build :transfer, :with_different_currencies,
              exchange_rate: 0.5}

            it_behaves_like 'income transaction' do
              let(:amount) {
                Money.new(transfer.amount_cents, transfer.from_currency).
                  exchange_to(transfer.to_currency).cents }
            end
            it_behaves_like 'outcome transaction'
          end
        end
      end
    end

    context 'with invalid data' do
      let(:bank_account) { create :bank_account, balance: 0 }
      let(:transfer) { build :transfer, bank_account_id: bank_account.id }

      context "doesn't create transactions" do
        it { expect{subject}.to change{Transaction.count}.by(0) }
      end

      context "add errors on transaction" do
        context "when transfer params wrong" do

          before do
            transfer.save
          end

          it { expect(transfer.errors.messages[:amount]).to include("Not enough money") }
        end
      end
    end
  end
end
