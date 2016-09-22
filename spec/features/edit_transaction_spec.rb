require 'rails_helper'

describe 'edit transaction', js: true do
  let(:user)         { create :user }
  let(:organization) { create :organization, with_user: user }
  let(:account)      { create :bank_account, organization: organization,
      residue: 9999999 }
  let(:category)     { create :category, organization: organization }
  let!(:transaction) { create :transaction, bank_account: account, category: category }

  before do
    sign_in user
    visit root_path
    find("##{dom_id(transaction)} .comment").click
    page.has_css?("#edit_row_transaction_#{transaction.id}")
  end

  subject{ page }

  context 'when bank_account is hidden' do
    let!(:account) { create :bank_account, organization: organization, visible: false }
    it "show disabled bank_account" do
      within "##{dom_id(transaction, :edit)} .transaction_bank_account.disabled" do
        expect(page).to have_css("input#transaction_bank_account[value='#{account.to_s}']")
      end
    end
  end

  context 'when category system' do
    let!(:category) { create :category, :receipt, organization: organization }

    it 'show as disabled input' do
      within "##{dom_id(transaction, :edit)} .transaction_category.disabled" do
        expect(page).to have_selector("input#transaction_category[value='Receipt']")
      end
    end
  end
end
