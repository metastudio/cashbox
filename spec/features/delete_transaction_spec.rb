require 'spec_helper'

describe 'delete transaction', js: true do
  include MoneyRails::ActionViewExtension

  let!(:user)         { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:category)     { create :category, organization: organization }
  let!(:account)      { create :bank_account, organization: organization}

  before do
    sign_in user
  end

  subject{ page }

  context "within pagination" do
    let!(:transactions) { create_list :transaction, 25, bank_account: account,
      category: category }
    let(:first_transaction) { transactions.last }
    let(:last_transaction)  { transactions.first }

    before do
      visit root_path
    end

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

  context "deleting", js: true do
    let!(:transactions) { create_list :transaction, 5, bank_account: account,
      category: category }
    let(:transaction)   { transactions.last }
    let!(:to_click)     { transaction.amount }

    before do
      visit root_path
      find("#transaction_#{transaction.id}",
        text: humanized_money_with_symbol(to_click)).click
      page.has_css?('simple_form edit_transaction')
      click_on "Remove"
    end

    it "removes transaction from list" do
      expect(subject).to_not have_content(humanized_money_with_symbol(to_click))
    end
  end
end
