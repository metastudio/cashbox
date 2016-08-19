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

  context "when updating bank account of transaction" do
    let(:amount) { 100 }
    let!(:new_account) { create :bank_account, organization: organization, currency: 'USD' }
    let!(:old_account) { create :bank_account, organization: organization, currency: 'USD' }
    let!(:transaction) { create :transaction, bank_account: old_account, amount: amount }

    before do
      visit root_path
      find("##{dom_id(transaction)} .comment").click
      page.has_css?("##{dom_id(transaction, :edit)}")
      within "##{dom_id(transaction, :edit)}" do
        select new_account, from: 'transaction[bank_account_id]'
      end
      click_on 'Update'
    end

    it "recalculate boths account's balances" do
      expect(subject).to have_css("##{dom_id(new_account)} td.amount",
        text: money_with_symbol(amount))
      expect(subject).to have_css("##{dom_id(old_account)} td.amount",
        text: money_with_symbol(0))
    end
  end

  context "transaction created by invoice" do
    let!(:invoice) { create :invoice, currency: "USD" }
    let!(:account) { create :bank_account, currency: "USD", organization: organization }
    let!(:transaction) { create :transaction, bank_account: account, invoice: invoice, amount: 200}

    before do
      visit root_path
      find("##{dom_id(transaction)} .comment").click
      page.has_css?("##{dom_id(transaction, :edit)}")
      click_on 'Update'
    end

    it "view link to invoice after the fields" do
      expect(subject).to have_link("Created from invoice")
      expect(find_link("Created from invoice")[:href]).to eq("/transactions/#{transaction.id}/edit")
    end
  end

  context "transaction created without invoice" do
    let!(:account) { create :bank_account, currency: "USD", organization: organization }
    let!(:transaction) { create :transaction, bank_account: account, amount: 200}

    before do
      visit root_path
      find("##{dom_id(transaction)} .comment").click
      page.has_css?("##{dom_id(transaction, :edit)}")
      click_on 'Update'
    end

    it "not view link to invoice after the fields" do
      expect(subject).not_to have_link("Created from invoice")
    end
  end

end
