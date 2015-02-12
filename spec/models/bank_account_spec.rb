require 'spec_helper'

describe BankAccount do
  context "association" do
    it { should belong_to(:organization) }
    it { should have_many(:transactions).dependent(:destroy)}
  end

  context "validation" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:currency) }
    it { should ensure_inclusion_of(:currency).in_array(%w(USD RUB)) }

    context 'custom' do
      it_behaves_like "has money ceiling", 'balance' do
        let(:max)    { Transaction::AMOUNT_MAX }
        let!(:model) { build :bank_account, balance: amount }
      end
    end
  end

  describe "soft delete" do
    let(:bank_account)  { create :bank_account }
    let(:amount)        { Money.new(100, bank_account.currency) }
    let!(:transaction)  { create :transaction, bank_account: bank_account,
      amount: amount }

    describe "bank_account destroy" do
      it "doesn't change balance on destroy" do
        expect{bank_account.destroy}.to_not change{bank_account.balance}.by(amount)
      end
    end

    describe "bank_account restore" do
      before do
        bank_account.destroy
      end

      it "doesn't change balance on restore" do
        expect{bank_account.restore}.to_not change{bank_account.balance}.by(amount)
      end
    end
  end
end
