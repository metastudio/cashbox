require 'spec_helper'

describe 'update transaction', js: true do
  include MoneyRails::ActionViewExtension

  let!(:user)         { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:category)     { create :category, organization: organization }
  let!(:account)      { create :bank_account, organization: organization}
  let!(:transactions) { create_list :transaction, 25, bank_account: account,
    category: category, amount_cents: 1000000 }

  before do
    sign_in user
    visit root_path
  end

  subject{ page }

  context "when updating" do
    let(:transaction) { organization.transactions.first }
    let(:new_amount)  { 5000 }
    let!(:difference) { transaction.amount - Money.new(new_amount * 100, transaction.currency) }
    let!(:new_total)  { transaction.bank_account.balance - difference }
    let!(:new_account_balance) { organization.bank_accounts.
      total_balance(transaction.currency) - difference }

    before do
      find(".transactions",
        text: humanized_money_with_symbol(transaction.amount)).click
      page.has_css?("#edit_row_transaction_#{transaction.id}")
      within ".transactions_list" do
        fill_in 'transaction[amount]', with: new_amount
        click_on 'Update Transaction'
      end
    end

    it "updates sidebar account balance" do
      expect(subject).
        to have_css("#bank_account_#{transaction.bank_account.id} td.amount",
          text: humanized_money_with_symbol(new_account_balance))
    end

    it "updates sidebar total balance" do
       expect(subject).
        to have_css("#sidebar",
          text: humanized_money_with_symbol(new_total))
    end
  end

end
