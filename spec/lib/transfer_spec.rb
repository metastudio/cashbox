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
    let(:transfer) { build :transfer }
  end
end
