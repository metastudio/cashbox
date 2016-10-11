require 'rails_helper'

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
    let!(:new_account_balance) { organization.bank_accounts.total_balance(transaction.currency) - difference }

    before do
      visit root_path
      find("#transaction_#{transaction.id} .comment").click
      page.has_css?("#edit_transaction_#{transaction.id}")
      within "#edit_transaction_#{transaction.id}" do
        page.execute_script("$(\"#edit_transaction_#{transaction.id} #transaction_amount\").val('');")
        fill_in 'transaction[amount]', with: new_amount
      end
      click_on 'Update'
      page.has_content?(/(Please review the problems below)/) # wait
      visit root_path
    end

    it "updates sidebar account balance and total balance" do
      expect(page).to have_css("#bank_account_#{transaction.bank_account.id} td.amount", text: money_with_symbol(new_account_balance))
      expect(page).to have_css("#sidebar", text: money_with_symbol(new_total))
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
      page.has_content?(/(Please review the problems below)/) # wait
    end

    it "recalculate boths account's balances" do
      expect(subject).to have_css("##{dom_id(new_account)} td.amount",
        text: money_with_symbol(amount))
      expect(subject).to have_css("##{dom_id(old_account)} td.amount",
        text: money_with_symbol(0))
    end
  end

  context "when transfer from usd to rub" do
    let!(:usd_account) { create :bank_account, organization: organization, currency: 'USD' }
    let!(:rub_account) { create :bank_account, organization: organization, currency: 'RUB' }
    let(:amount) { 999 }
    let(:calculate_sum) { 76619.2 }
    let(:exchange_rate) { "76.6959" }

    before do
      visit root_path
      click_on 'Add...'
      page.has_content?(/(Please review the problems below)/) # wait
      click_on 'Transfer'
      select usd_account, from: 'transfer[bank_account_id]'
      select rub_account, from: 'transfer[reference_id]'
      fill_in 'transfer[amount]', with: amount
      fill_in 'transfer[calculate_sum]', with: calculate_sum
      find('input[name="transfer[exchange_rate]"]').trigger('focus')
      page.has_content?(/(Please review the problems below)/)
    end

    it "calculate exchange rate with four decimal places" do
      expect(find('input[name="transfer[exchange_rate]"]').value).to eq(exchange_rate)
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
    end

    it "view link to invoice after the fields" do
      expect(page).to have_link "Created from invoice", href: invoice_path(invoice)
    end
  end

  context "transaction created without invoice" do
    let!(:account) { create :bank_account, currency: "USD", organization: organization }
    let!(:category) { create :category, :income, organization: organization }
    let!(:transaction) { create :transaction, bank_account: account, amount: 200}

    before do
      visit root_path
      find("##{dom_id(transaction)} .comment").click
      page.has_css?("##{dom_id(transaction, :edit)}")
    end

    it "not view link to invoice after the fields" do
      expect(page).not_to have_link("Created from invoice")
    end
  end

  context "transaction form have categories only with transaction category type" do
    let!(:category) { create :category, :income, organization: organization }
    let!(:inc_category) { create :category, :income, organization: organization }
    let!(:exp_category) { create :category, :expense, organization: organization }
    let!(:transaction) { create :transaction, category: category, bank_account: account }

    before do
      visit root_path
      find("##{dom_id(transaction)} .comment").click
      page.has_css?("##{dom_id(transaction, :edit)}")
      click_on 'Update'
    end

    subject { page.all('select#transaction_category_id option').map{ |e| e.text } }

    it "have category name in category_name collection" do
      expect(subject).to include(category.name);
      expect(subject).to include(inc_category.name);
      expect(subject).to_not include(exp_category.name);
    end
  end
end
