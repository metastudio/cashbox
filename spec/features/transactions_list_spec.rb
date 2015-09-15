require 'spec_helper'

describe 'Transactions list' do
  include MoneyHelper

  let(:user) { create :user, :with_organizations }
  let(:org1) { user.organizations.first }
  let(:org2) { user.organizations.last }
  let(:org1_ba) { create :bank_account, organization: org1, currency: 'USD' }
  let(:org2_ba) { create :bank_account, organization: org2 }
  let(:category_org1)     { create :category, organization: org1 }
  let!(:org1_transaction) { create :transaction, bank_account: org1_ba,
    category: category_org1, amount: 100 }
  let!(:org2_transaction) { create :transaction, bank_account: org2_ba,
    category: category_org1, amount: 500 }

  before do
    sign_in user
  end

  subject { page }

  it "root page displays current organization's transactions" do
    expect(subject).to have_content(money_with_symbol(org1_transaction.amount))
  end

  it "root page doesn't display another transactions" do
    expect(subject).to_not have_content(money_with_symbol(org2_transaction.amount))
  end

  describe "links" do
    describe "category" do
      let(:category) { org1_transaction.category.name }

      before do
        within "#transaction_#{org1_transaction.id}" do
          click_on category
        end
      end
      it "opens filtered root" do
        expect(page).to have_content(category)
      end
    end

    describe 'bank account' do
      before do
        within "#transaction_#{org1_transaction.id}" do
          click_on org1_ba.name
        end
      end
      it "opens filtered root" do
        expect(page).to have_content(org1_ba.name)
      end
    end
  end

  context 'when switch organization' do
    before do
      click_on 'Change organization'
      within "##{dom_id(org2, :switch)}" do
        click_on 'Switch'
      end
    end

    it "displays right transactions" do
      expect(subject).to have_content(money_with_symbol(org2_transaction.amount))
    end

    it "doesn't display another organization transactions" do
      expect(subject).to_not have_content(money_with_symbol(org1_transaction.amount))
    end
  end

  context "pagination" do
    include_context 'transactions pagination'
    let!(:transactions) { FactoryGirl.create_list(:transaction,
      transactions_count, bank_account: org1_ba).reverse }

    before do
      visit root_path
    end

    it "lists first page transactions" do
      within ".transactions" do
        transactions.first(paginated).each do |transaction|
          expect(subject).to have_css('td', text: money_with_symbol(transaction.amount))
        end
      end
    end

    it "doesnt list second page transactions" do
      within ".transactions" do
        transactions.last(5).each do |transaction|
          expect(subject).to_not have_css('td', text: money_with_symbol(transaction.amount))
        end
      end
    end

    context "switch to second page", js: true do
      before do
        within '.pagination' do
          click_on '2'
        end
      end

      it "doesnt list first page transactions" do
        within ".transactions" do
          transactions.first(paginated).each do |transaction|
            expect(subject).to_not have_css('td', text: money_with_symbol(transaction.amount))
          end
        end
      end

      it "lists 5 last transactions" do
        within ".transactions" do
          transactions.last(5).each do |transaction|
            expect(subject).to have_css('td', text: money_with_symbol(transaction.amount))
          end
        end
      end
    end
  end

  context "table" do
    before do
      visit root_path
    end

    it "shows right column names" do
      within ".transactions thead tr" do
        expect(subject).to have_content('Amount')
        expect(subject).to have_content('Category')
        expect(subject).to have_content('Account')
        expect(subject).to have_content('Comment')
        expect(subject).to have_content('Date')
      end
    end

    it "shows right columns content" do
      within "#transaction_#{org1_transaction.id}" do
        expect(subject).to have_content(money_with_symbol(org1_transaction.amount))
        expect(subject).to have_content(org1_transaction.category.name)
        expect(subject).to have_content(org1_transaction.bank_account.name)
        expect(subject).to have_content(org1_transaction.comment)
        expect(subject).to have_content(I18n.l(org1_transaction.date))
      end
    end

    context "paint right css-class" do
      let(:expense) { create :category, :expense, organization: org1 }
      let!(:org1_transaction2) { create :transaction, category: expense,
        bank_account: org1_ba, amount: 50 }

      before do
        visit root_path
      end

      it "'positive' for positive" do
        expect(subject).to have_css(".transaction.positive#transaction_#{org1_transaction.id}")
      end

      it "'negative' for negative" do
        expect(subject).to have_css(".transaction.negative#transaction_#{org1_transaction2.id}")
      end
    end
  end

  context "sidebar" do
    let!(:org1_ba2)        { create :bank_account, organization: org1, currency: 'RUB' }
    let!(:ba2_transaction) { create :transaction, bank_account: org2_ba,
      category: category_org1, amount: 500 }

    before do
      visit root_path
    end

    it 'display exhanged amount' do
      within '#total_balance' do
        expect(page).to have_content(
          money_with_symbol org1_ba2.balance.exchange_to(org1.default_currency))
      end
    end

    it 'display exchange date' do
      within '#total_balance' do
        expect(page).to have_xpath("//a[contains(concat(' ', @class, ' '), ' exchange-helper ') and contains(@title, '#{I18n.l(Money.default_bank.rates_updated_at)}')]")
      end
    end

    it 'display exchange rate' do
      within '#total_balance' do
        expect(page).to have_xpath("//a[contains(concat(' ', @class, ' '), ' exchange-helper ') and contains(@title, '#{Money.default_bank.get_rate(org1_ba2.currency, org1.default_currency).round(4)}')]")
      end
    end

    it 'display total balance in default currency' do
      within '#total_balance' do
        expect(page).to have_content money_with_symbol (org1_ba.balance.exchange_to(org1.default_currency) + org1_ba2.balance.exchange_to(org1.default_currency))
      end
    end
  end
end
