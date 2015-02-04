require 'spec_helper'

describe 'soft delete' do
  let(:user) { create :user, :with_organizations }
  let(:org)  { user.organizations.first }
  let(:ba_org)        { create :bank_account, organization: org }
  let(:amount)        100
  let!(:transaction)  { create_list :transaction, bank_account: ba_org, amount: amount }

  describe "bank_account restore" do
    before do
      ba_org.destroy
    end

    it "doesn't change balance on restore" do
      expect{ba_org.restore}.to_not change{ba_org.balance}
    end
  end

  describe "transaction destroy" do
    it "changes balance" do
      expect{transaction.destroy}.to change{ba_org.balance}.by(amount)
    end

    context "then restore" do
      before do
        transaction.destroy
      end
      it "changes balance" do
        expect{transaction.restore}.to change{ba_org.balance}.by(amount)
      end
    end
  end
end
