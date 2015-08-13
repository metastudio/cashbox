require 'spec_helper'
describe 'update transaction', js: true do
  include MoneyHelper

  let!(:user)         { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:account)      { create :bank_account, organization: organization}

  before { sign_in user }

  subject{ page }

  context "pagination" do
    include_context 'transactions pagination'
    let!(:transactions) { create_list :transaction, transactions_count,
      bank_account: account }

    before { visit root_path }

    context "first page" do
      before do
        id = transactions.last.id
        find("#transaction_#{id} .comment").click
        page.has_css?("#edit_transaction_#{id}")
      end

      it "shows update form on row click" do
        expect(subject).to have_selector('#submit_btn')
      end
    end

    context "last page" do
      before do
        click_on 'Last'
        id = transactions.first.id
        find("#transaction_#{id} .comment").click
        page.has_css?("#edit_transaction_#{id}")
      end

      it "shows update form on row click" do
        expect(subject).to have_selector('#submit_btn')
      end
    end
  end

  context "when updating" do
    let(:transaction) { create :transaction, bank_account: account, amount: 10000000 }
    let(:new_amount)  { 5000000 }
    let!(:difference) { transaction.amount - Money.new(new_amount * 100, transaction.currency) }
    let!(:new_total)  { transaction.bank_account.balance - difference }
    let!(:new_account_balance) { organization.bank_accounts.
      total_balance(transaction.currency) - difference }

    before do
      visit root_path
      find("#transaction_#{transaction.id} .comment").click
      page.has_css?("#edit_transaction_#{transaction.id}")
      within "#edit_transaction_#{transaction.id}" do
        page.execute_script("$(\"#edit_transaction_#{transaction.id} #transaction_amount\").val('');")
        fill_in 'transaction[amount]', with: new_amount
      end
      click_on 'Update'
    end

    it "updates sidebar account balance" do
      expect(subject).
        to have_css("#bank_account_#{transaction.bank_account.id} td.amount",
          text: money_with_symbol(new_account_balance))
    end

    it "updates sidebar total balance" do
       expect(subject).
        to have_css("#sidebar",
          text: money_with_symbol(new_total))
    end
  end
end
