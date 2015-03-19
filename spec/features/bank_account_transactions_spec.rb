require 'spec_helper'

describe 'Bank account transactions' do
  let(:user)      { create :user }
  let(:org)       { create :organization, with_user: user }
  let(:account)   { create :bank_account, organization: org }
  let(:account2)  { create :bank_account, organization: org }
  let!(:transaction1) { create :transaction, bank_account: account }
  let!(:transaction2) { create :transaction, bank_account: account }
  let!(:transaction3) { create :transaction, bank_account: account2 }
  let!(:transaction4) { create :transaction, bank_account: account2 }

  before do
    sign_in user
    visit root_path
  end

  subject { page }

  it "has links to bank accounts in sidebar" do
    within "#sidebar" do
      expect(subject).to have_link account.to_s
      expect(subject).to have_link account2.to_s
    end
  end

  context 'when account clicked' do
    before do
      within "#sidebar" do
        click_on account.to_s
      end
    end

    it "displays selected account's transactions " do
      within ".transactions" do
        expect(subject).to have_css("#transaction_#{transaction1.id}")
        expect(subject).to have_css("#transaction_#{transaction2.id}")
      end
    end

    it "not display not own transactions" do
      within ".transactions" do
        expect(subject).to_not have_css("#transaction_#{transaction3.id}")
        expect(subject).to_not have_css("#transaction_#{transaction4.id}")
      end
    end
  end
end
