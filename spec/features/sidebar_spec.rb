require 'spec_helper'

describe 'sidebar' do
  let(:user)    { create :user, :with_organization }
  let(:org)     { user.organizations.first }
  let!(:account) { create :bank_account, organization: org, balance: 50000 }
  let!(:account3){ create :bank_account, organization: org, balance: 0 }

  before do
    sign_in user
  end

  subject { page }

  context "right classes for accounts" do
    before do
      visit root_path
    end
    it "for positive" do
      within '.positive' do
        expect(page).to have_content account.to_s
      end
    end

    it "for empty" do
      within '.empty' do
        expect(page).to have_content account3.to_s
      end
    end
  end
end
