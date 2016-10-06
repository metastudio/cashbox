require 'rails_helper'

describe 'create transaction', js: true do
  include MoneyHelper

  let!(:user)         { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:category)     { create :category, :income, organization: organization }
  let!(:exp_category) { create :category, :expense, organization: organization }
  let!(:account)      { create :bank_account, residue: 99999999,
    organization: organization }

  let(:amount)            { 1232.23 }
  let(:amount_str)        { '1,232.23' }
  let(:category_name)     { category.name }
  let(:exp_category_name) { exp_category.name }
  let(:account_name)      { account.name }
  let(:comment)           { "Test transaction" }

  let(:transactions) { organization.transactions.where(bank_account_id: account.id, category_id: category.id) }

  def create_transaction
    visit root_path
    click_on 'Add...'
    page.has_content?(/(Please review the problems below)/) # wait
    within '#new_transaction' do
      fill_in 'transaction[amount]', with: amount_str
      select category_name, from: 'transaction[category_id]' if category_name.present?
      select account_name, from: 'transaction[bank_account_id]' if account_name.present?
      fill_in 'transaction[comment]', with: comment
    end
    click_on 'Create'
    page.has_content?(/(Please review the problems below)|(#{amount_str})/) # wait after page rerender
  end

  subject{ create_transaction; page }

  before :each do
    sign_in user
  end

  context 'form select' do
    context 'choose bank account' do
      before do
        visit root_path
        click_on 'Add...'
      end

      it "displays account name with currency, displays category name and not display expense category name" do
        within '#transaction_bank_account_id' do
          expect(page).to have_css('optgroup', text: account.to_s)
        end
        expect(page).to have_select('transaction[category_id]', with_options: [category_name])
        expect(page).to_not have_select('transaction[category_id]', with_options: [exp_category_name])
      end
    end
  end

  context "with valid data" do
    it "creates a new transaction" do
      expect{ subject }.to change{ transactions.count }.by(1)
    end

    it "shows created transaction in transactions list" do
      create_transaction
      within ".transactions" do
        expect(page).to have_content(amount_str)
      end
    end

    context "when income category selected" do
      it "creates transaction with positive amount" do
        expect{ subject }.to change{ transactions.where(amount_cents: amount * 100).count }.by(1)
      end
    end

    context "expense category" do
      before do
        visit root_path
        click_on 'Add...'
        page.has_content?(/(Please review the problems below)|(#{amount_str})/) # wait
        click_on 'Expense'
      end

      it "not present income category and present expense category" do
        expect(page).to have_css('#new_transaction', visible: true)
        expect(page).to_not have_select('transaction[category_id]', with_options: [category_name])
        expect(page).to have_css('#new_transaction', visible: true)
        expect(page).to have_select('transaction[category_id]', with_options: [exp_category_name])
      end
    end

    context "updates sidebar" do
      let(:new_amount) { Money.new(amount * 100, account.currency) }
      let!(:new_account_balance) { account.balance + new_amount }
      let!(:new_total) { organization.bank_accounts.
        total_balance(account.currency) + new_amount }

      it "recalculates bank account amount" do
        expect(subject).
          to have_css("#bank_account_#{account.id} td.amount",
            text: money_with_symbol(new_account_balance))
      end

      it "recalculates total balance" do
        create_transaction
        page.find('a.dropdown-toggle[data-target="#dropdown-total"]').click
        expect(page).
          to have_css("#total_balance", text: money_with_symbol(new_total))
      end
    end
  end

  context "without comment" do
    let(:comment) { nil }

    it "creates transaction without errors" do
      expect{ subject }.to change{ transactions.count }.by(1)
    end
  end

  context "with not selected category" do
    let(:category_name) { nil }

    it "doesn't create transaction and shows error for category field" do
      expect{ subject }.to_not change{ transactions.count }
      expect(subject).to have_inline_error("can't be blank").for_field('transaction_category_id')
    end
  end

  context "with not selected account" do
    let(:account_name) { nil }

    it "doesn't create transaction and shows error for account field" do
      expect{ subject }.to_not change{ transactions.count }
      expect(subject).to have_inline_error("can't be blank").for_field('transaction_bank_account_id')
    end
  end

  context "when account is hidden" do
    let(:account) { create :bank_account, organization: organization, visible: false }

    before do
      visit root_path
    end

    it "doesn't display account in select" do
      expect(page).to_not have_content(account.to_s)
    end
  end

  context "with leave open checked" do
    before do
      visit root_path
      click_on 'Add...'
      page.has_content?(/(Please review the problems below)/) # wait
      within '#new_transaction' do
        fill_in 'transaction[amount]', with: amount_str
        select category_name, from: 'transaction[category_id]' if category_name.present?
        select account_name, from: 'transaction[bank_account_id]' if account_name.present?
        fill_in 'transaction[comment]', with: comment
        find('#transaction_leave_open').set(true)
      end
      click_on 'Create'
      page.has_content?(/(Please review the problems below)|(#{amount_str})/) # wait after page rerender
    end

    it "create transaction and fill form by old transaction data" do
      expect(page).to have_css('#new_transaction', visible: true)
      expect(page).to have_content("Transaction was created successfully!")
      within '#new_transaction' do
        expect(page).to have_field('Amount', with: amount_str)
        expect(page).to have_field('Category', with: category.id)
        expect(page).to have_field('Bank account', with: account.id)
        expect(page).to have_field('Comment', with: comment)
      end
    end
  end
end
