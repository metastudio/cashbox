require 'spec_helper'

describe 'create transaction', js: true do
  let!(:user)         { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:category)     { create :category, organization: organization }
  let!(:account)      { create :bank_account, organization: organization}

  let(:amount)        { 123.23 }
  let(:category_name) { category.name }
  let(:account_name)  { account.name }
  let(:comment)       { "Test transaction" }

  let(:transactions) { organization.transactions.where(bank_account_id: account.id, category_id: category.id) }

  def create_transaction
    # puts "organization = #{organization.inspect}"
    # puts "all categories = #{Category.all.inspect}"
    # puts "category name = #{category_name.inspect}"
    # puts page.body.to_s.inspect
    visit root_path
    within '#new_transaction' do
      fill_in 'transaction[amount]', with: amount
      select category_name, from: 'transaction[category_id]' if category_name.present?
      select account_name, from: 'transaction[bank_account_id]' if account_name.present?
      fill_in 'transaction[comment]', with: comment
      click_on 'Create Transaction'
    end
    page.has_content?(amount) # wait after page rerender
  end

  subject{ create_transaction; page }

  before :each do
    sign_in user
  end

  context "with valid data" do
    it "creates a new transaction" do
      expect{ subject }.to change{ transactions.count }.by(1)
    end

    it "shows created transaction at the top of transactions list" do
      pending
    end

    context "when income category selected" do
      let!(:category) { create :category, :income, organization: organization }

      it "creates transaction with positive amount" do
        expect{ subject }.to change{ transactions.where(amount_cents: amount * 100.0).count }.by(1)
      end
    end

    context "when expense category selected" do
      let!(:category) { create :category, :expense, organization: organization }

      it "creates transaction with negative amount" do
        expect{ subject }.to change{ transactions.where(amount_cents: amount * -100.0).count }.by(1)
      end
    end
  end

  context "without comment" do
    let(:comment) { nil }

    it "creates transaction without errors" do
      expect{ subject }.to change{ transactions.count }.by(1)
    end
  end

  context "with negative amount" do
    let(:amount) { -1234 }

    it "doesn't create transaction" do
      expect{ subject }.to_not change{ transactions.count }
    end

    it "shows error for amount field" do
      expect(subject).to have_inline_error("must be greater than 0").for_field_name('transaction[amount]')
    end
  end

  context "with non numeric data in amount field" do
    let(:amount) { "abc" }

    it "doesn't create transaction" do
      expect{ subject }.to_not change{ transactions.count }
    end

    it "shows error for amount field" do
      expect(subject).to have_inline_error("must be greater than 0").for_field_name('transaction[amount]')
    end
  end

  context "with blank data in amount field" do
    let(:amount) { nil }

    it "doesn't create transaction" do
      expect{ subject }.to_not change{ transactions.count }
    end

    it "shows error for amount field" do
      expect(subject).to have_inline_error("must be greater than 0").for_field_name('transaction[amount]')
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
