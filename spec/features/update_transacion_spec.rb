require 'spec_helper'

describe 'update transaction', js: true do
  include MoneyRails::ActionViewExtension

  let!(:user)         { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:category)     { create :category, organization: organization }
  let!(:account)      { create :bank_account, organization: organization}

  let!(:transactions) { create_list :transaction, 25, bank_account: account,
    category: category }

  before do
    sign_in user
    visit root_path
  end

  subject{ page }

  context "first page" do
    before do
      find(".transactions",
        text: humanized_money_with_symbol(organization.transactions.first.amount)).click
      page.has_css?('simple_form edit_transaction')
    end

    it "shows update form on row click" do
      expect(subject).to have_selector("input[type=submit][value='Update Transaction']")
    end
  end

  context "next page" do
    before do
      click_on 'Last'
      find(".transactions",
        text: humanized_money_with_symbol(organization.transactions.last.amount)).click
      page.has_css?('simple_form edit_transaction')
    end

    it "shows update form on row click" do
      expect(subject).to have_selector("input[type=submit][value='Update Transaction']")
    end
  end
end
