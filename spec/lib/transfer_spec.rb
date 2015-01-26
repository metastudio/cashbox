require 'spec_helper'
require 'transfer'

describe Transfer do
  subject { Transfer.new }

  context "validation" do
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:bank_account_id) }
    it { should validate_presence_of(:reference_id) }
    it { should validate_numericality_of(:comission).is_greater_than(0) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }

    context "custom validations" do
      let(:bank_account1) { create :bank_account, balance: 100 }
      let(:bank_account2) { create :bank_account, balance: 200 }
      let(:reference_id ) { bank_account2.id }
      let(:transfer)      { build :transfer, bank_account_id: bank_account1.id,
        reference_id: reference_id }

      subject { transfer }
      describe "transfer_account" do
        let(:reference_id) { bank_account1.id }
        it 'is invalid' do
          expect(subject).to be_invalid
          expect(subject.errors_on(:reference_id)).
            to include("Can't transfer to same account")
        end
      end

      describe "transfer_amount" do
        it 'is invalid' do
          expect(subject).to be_invalid
          expect(subject.errors_on(:amount)).
            to include("Not enough money")
        end
      end
    end
  end

  describe "#save(transaction)" do
    let(:bank_account) { create :bank_account, balance: 99999 }
    let(:reference)    { create :bank_account, balance: 99999 }
    let(:transaction)  { build :transaction, :transfer, bank_account: bank_account,
       reference: reference, amount: 700, comission: 500 }
    let(:transfer)     { Transfer.new(amount: transaction.amount, comment:
      transaction.comment, comission: transaction.comission, bank_account_id:
      transaction.bank_account_id, reference_id: transaction.reference_id) }

    subject { transfer.save(transaction) }

    context 'with valid data' do
      context "create 2 transactions" do
        it { expect{subject}.to change{Transaction.count}.by(2) }

        describe 'attributes' do
          let(:inc) { subject.first }
          let(:out) { subject.last }

          describe 'income' do
            it { expect(inc.amount.to_f).to eq transaction.amount.to_f }
            it { expect(inc.comission).to eq transaction.comission }
            it { expect(inc.comment).to eq (transaction.comment.to_s +
              "\nComission: " + transaction.comission.to_s) }
            it { expect(inc.bank_account_id).to eq transaction.reference_id }
            it { expect(inc.reference_id).to eq transaction.bank_account_id }
            it { expect(inc.category_id).to eq Category.find_by(
              Category::CATEGORY_BANK_INCOME_PARAMS).id }
            it { expect(inc.transaction_type).to eq 'Receipt' }
          end

          describe 'outcome' do
            it { expect(out.amount.to_f).to eq (transaction.amount.to_f + transaction.comission) * (-1) }
            it { expect(out.comission).to eq transaction.comission }
            it { expect(out.comment).to eq transaction.comment.to_s +
              "\nComission: " + transaction.comission.to_s }
            it { expect(out.bank_account_id).to eq transaction.bank_account_id }
            it { expect(out.reference_id).to eq transaction.reference_id }
            it { expect(out.category_id).to eq Category.find_by(
              Category::CATEGORY_BANK_EXPENSE_PARAMS).id}
            it { expect(out.transaction_type).to eq 'Transfer'}
          end
        end
      end
    end

    context 'with invalid data' do
      context "doesn't create transactions" do
        let(:bank_account) { create :bank_account, balance: 0 }
        it { expect{subject}.to change{Transaction.count}.by(0) }
      end

      context "add errors on transaction" do
        context "when transfer params wrong" do
          let(:bank_account) { create :bank_account, balance: 0 }

          before do
            transfer.save(transaction)
          end

          it { expect(transaction.errors.messages[:amount]).to include("Not enough money") }
        end
      end
    end
  end
end
