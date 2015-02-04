require 'spec_helper'

describe 'soft delete' do
  let(:user) { create :user, :with_organizations }
  let(:org)  { user.organizations.first }
  let(:ba_org)  { create :bank_account, organization: org }
  let!(:ba_transactions)  { create_list :transaction, 2, bank_account: ba_org, amount: 100 }

  describe "bank_account restore" do
    before do
      ba_org.destroy
    end

    it "doesn't change balance on restore" do
      expect{ba_org.restore}.to_not change{ba_org.balance}
    end
  end
end
