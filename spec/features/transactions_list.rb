require 'spec_helper'

describe 'Transactions list' do
  let(:user) { create :user, :with_organizations }
  let(:org1) { user.organizations.first }
  let(:org2) { user.organizations.last }
  let(:org1_ba) { create :bank_account, organization: org1}
  let(:org2_ba) { create :bank_account, organization: org2}
  let(:org1_transaction) { create :transaction, bank_account: org1, amount: 100 }
  let(:org2_transaction) { create :transaction, bank_account: org2, amount: 500 }

  before do
    sign_in user
  end

  subject { page }

  it "root page displays current organization's transactions" do
    expect(subject).to have_content org1_transaction.amount }
  end

  it "root page doesn't display another transactions" do
    expect(subject).to_not have_content org2_transaction.amount }
  end

  context 'when switch organization' do
    before do
      within "#switch_organization" do
        click_on org2.name
      end
    end

    it "displays right transactions" do
      expect(subject).to have_content org2_transaction.amount }
    end

    it "doesn't display another organization transactions" do
      expect(subject).to_not have_content org1_transaction.amount }
    end
  end
end
