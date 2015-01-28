require 'spec_helper'
require 'transfer'

describe Transfer do
  subject { Transfer.new }

  context "validation" do
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:bank_account_id) }
    it { should validate_numericality_of(:comission).is_greater_than(0) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }

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
    end
  end

  describe "#save" do
    let(:transfer) { build :transfer }

    subject { transfer.save }

    context 'with valid data' do
      context "create 2 transactions" do
        it { expect{subject}.to change{Transaction.count}.by(2) }

        describe 'attributes' do
          before do
            transfer.save
          end

          describe 'income' do
            let(:inc) { transfer.inc_transaction }
            it { expect(inc.amount_cents).to eq transfer.amount_cents }
            it { expect(inc.comment).to eq (transfer.comment.to_s +
              "\nComission: " + transfer.comission.to_s) }
            it { expect(inc.bank_account_id).to eq transfer.reference_id }
            it { expect(inc.category_id).to eq Category.find_by(
              Category::CATEGORY_BANK_INCOME_PARAMS).id }
          end

          describe 'outcome' do
            let(:out) { transfer.out_transaction }
            it { expect(out.amount_cents).to eq (transfer.amount_cents + transfer.comission_cents) * (-1) }
            it { expect(out.comment).to eq (transfer.comment.to_s +
              "\nComission: " + transfer.comission.to_s) }
            it { expect(out.bank_account_id).to eq transfer.bank_account_id }
            it { expect(out.category_id).to eq Category.find_by(
              Category::CATEGORY_BANK_EXPENSE_PARAMS).id}
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
