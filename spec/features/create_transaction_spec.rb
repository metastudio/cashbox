require 'spec_helper'

describe 'create transaction', js: true do
  include MoneyRails::ActionViewExtension

  let!(:user)         { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:category)     { create :category, organization: organization }
  let!(:account)      { create :bank_account, :with_transactions,
    organization: organization}

  let(:amount)        { 123.23 }
  let(:category_name) { category.name }
  let(:account_name)  { account.name }
  let(:comment)       { "Test transaction" }

  let(:transactions) { organization.transactions.where(bank_account_id: account.id, category_id: category.id) }

  def create_transaction
    visit root_path
    within '#new_transaction' do
      fill_in 'transaction[amount]', with: amount
      select category_name, from: 'transaction[category_id]' if category_name.present?
      select account_name, from: 'transaction[bank_account_id]' if account_name.present?
      fill_in 'transaction[comment]', with: comment
      click_on 'Create'
    end
    page.has_content?(/(Please review the problems below)|(#{amount})/) # wait after page rerender
  end

  subject{ create_transaction; page }

  before :each do
    sign_in user
  end

  context "with valid data" do
    it "creates a new transaction" do
      expect{ subject }.to change{ transactions.count }.by(1)
    end

    it "shows created transaction in transactions list" do
      create_transaction
      within ".transactions" do
        expect(page).to have_content(amount)
      end
    end

    context "when income category selected" do
      let!(:category) { create :category, :income, organization: organization }

      it "creates transaction with positive amount" do
        expect{ subject }.to change{ transactions.where(amount_cents: amount * 100).count }.by(1)
      end
    end

    context "when expense category selected" do
      let!(:category) { create :category, :expense, organization: organization }

      it "creates transaction with negative amount" do
        expect{
          subject
        }.to change{ transactions.where(amount_cents: amount * -100).count }.by(1)
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
            text: humanized_money_with_symbol(new_account_balance))
      end

      it "recalculates total balance" do
        expect(subject).
          to have_css("#sidebar",
            text: humanized_money_with_symbol(new_total))
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

    it "doesn't create transaction" do
      expect{ subject }.to_not change{ transactions.count }
    end

    it "shows error for category field" do
      expect(subject).to have_inline_error("can't be blank").for_field_name('transaction[category_id]')
    end
  end

  context "with not selected account" do
    let(:account_name) { nil }

    it "doesn't create transaction" do
      expect{ subject }.to_not change{ transactions.count }
    end

    it "shows error for account field" do
      expect(subject).to have_inline_error("can't be blank").for_field_name('transaction[bank_account_id]')
    end
  end
end
