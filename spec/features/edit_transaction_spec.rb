require 'spec_helper'

describe 'edit transaction', js: true do

  let(:user)         { create :user }
  let(:organization) { create :organization, with_user: user }
  let(:account)      { create :bank_account, organization: organization }
  let!(:transaction) { create :transaction, bank_account: account }


  before do
    sign_in user
    visit root_path
    find("#transaction_#{transaction.id}").click
    page.has_css?("#edit_row_transaction_#{transaction.id}")
  end

  subject{ page }

  context 'when bank_account is hidden' do
    let!(:account)      { create :bank_account, organization: organization, visible: false }

    it "show disabled bank_account" do
      within "#edit_row_transaction_#{transaction.id}" do
        expect(page).to have_css('.disabled.transaction_bank_account', text: account.to_s)
      end
    end
  end

  context "close form" do
    before do
      within "#edit_row_transaction_#{transaction.id}" do
        click_on '×'
      end
    end

    it "removes form" do
      expect(page).to_not have_selector('.close')
    end
  end
end
