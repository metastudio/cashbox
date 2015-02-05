require 'spec_helper'

describe Category do
  context "association" do
    it { should belong_to(:organization) }
    it { should have_many(:transactions).dependent(:restrict_with_exception) }
  end

  context "validation" do
    it { should validate_presence_of(:type) }
    it { should validate_presence_of(:name) }
    it { should ensure_inclusion_of(:type).in_array(%w[Income Expense]) }

    context "if system" do
      before { subject.stub(:system?) { true } }
      it { should_not validate_presence_of(:organization_id) }
    end

    context "if not system" do
      before { subject.stub(:system?) { false } }
      it { should validate_presence_of(:organization_id) }
    end
  end

  context "soft delete" do
    let(:bank_account)  { create :bank_account }
    let(:amount)        { Money.new(100, bank_account.currency) }
    let(:category)      { create :category, organization: bank_account.organization }
    let!(:transaction)  { create :transaction, bank_account: bank_account,
      amount: amount, category: category }

    describe "category destroy" do
      it "changes balance" do
        expect{category.destroy}.to change{bank_account.balance}.by(-amount)
      end

      context "then restore" do
        before do
          category.destroy
        end

        it "changes balance" do
          expect{category.restore}.to change{bank_account.balance}.by(amount)
        end
      end
    end
  end
end
