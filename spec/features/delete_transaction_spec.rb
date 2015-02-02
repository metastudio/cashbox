require 'spec_helper'

describe 'delete transaction', js: true do
  include MoneyRails::ActionViewExtension

  let!(:user)         { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:category)     { create :category, organization: organization }
  let!(:account)      { create :bank_account, organization: organization}

  let!(:transactions) { create_list :transaction, 25, bank_account: account,
    category: category }
  let(:first_transaction) { transactions.last }
  let(:last_transaction)  { transactions.first }

  before do
    sign_in user
    visit root_path
  end

  subject{ page }

  context "first page" do
    before do
      find("#transaction_#{first_transaction.id}",
        text: humanized_money_with_symbol(first_transaction.amount)).click
      page.has_css?('simple_form edit_transaction')
    end

    it "shows delete form on row click" do
      expect(subject).to have_link("Remove", href: transaction_path(first_transaction))
    end
  end

  context "next page" do
    before do
      click_on 'Last'
      find("#transaction_#{last_transaction.id}",
        text: humanized_money_with_symbol(last_transaction)).click
      page.has_css?('simple_form edit_transaction')
    end

    it "shows delete form on row click" do
      expect(subject).to have_link("Remove", href: transaction_path(last_transaction))
    end
  end
end
