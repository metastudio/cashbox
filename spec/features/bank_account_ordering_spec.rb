require 'rails_helper'

describe 'Bank accounts after drag&drop' do
  context 'ordered corresponing to row_order' do
    let(:user)      { create :user }
    let(:org)       { create :organization, with_user: user }
    let(:account5)  { create :bank_account, organization: org }
    let(:account4)  { create :bank_account, organization: org }
    let(:account3)  { create :bank_account, organization: org }
    let(:account2)  { create :bank_account, organization: org }
    let(:account1)  { create :bank_account, organization: org }

    before do
      account1.update_attribute(:position, 1)
      account2.update_attribute(:position, 2)
      account3.update_attribute(:position, 3)
      account4.update_attribute(:position, 4)
      account5.update_attribute(:position, 5)

      sign_in user
      visit bank_accounts_path
    end

    subject { page }

    it do
      expect(subject).to have_selector("tr:nth-of-type(1)", text: account1.name)
      expect(subject).to have_selector("tr:nth-of-type(2)", text: account2.name)
      expect(subject).to have_selector("tr:nth-of-type(3)", text: account3.name)
      expect(subject).to have_selector("tr:nth-of-type(4)", text: account4.name)
      expect(subject).to have_selector("tr:nth-of-type(5)", text: account5.name)
    end
  end
end
