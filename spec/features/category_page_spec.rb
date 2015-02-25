require 'spec_helper'

describe 'category page' do
  let(:user)          { create :user }
  let(:organization)  { create :organization, with_user: user }
  let!(:account)      { create :bank_account, organization: organization }
  let(:amount)        { 150.66 }
  let(:account_name)  { account.name }

  before do
    sign_in user
  end

  subject{ page }

  describe "pagination" do
    let(:paginated)        { 10 }
    let(:categories_count) { paginated + 10 }

    let!(:categories) { create_list :category, categories_count,
      organization: organization }

    before do
      visit categories_path
    end

    it "lists first page categories" do
      within ".categories" do
        categories.last(paginated).each do |category|
          expect(subject).to have_selector('td', text: category.name)
        end
      end
    end

    it "doesnt list last page categories" do
      within ".categories" do
        categories.first(categories_count - paginated).each do |category|
          expect(subject).to_not have_selector('td', text: category.name)
        end
      end
    end

    context "switch to second page" do
      before do
        within '.pagination' do
          click_on '2'
        end
      end

      it "doesnt list first page categories" do
        within ".categories" do
          categories.last(paginated).each do |category|
            expect(subject).to_not have_selector('td', text: category.name)
          end
        end
      end

      it "lists last categories" do
        within ".categories" do
          categories.first(categories_count - paginated).each do |category|
            expect(subject).to have_selector('td', text: category.name)
          end
        end
      end
    end
  end

  describe 'when opened via transactions table column' do
    let(:cat)          { create :category, organization: organization }
    let!(:transaction) { create :transaction, bank_account: account, category: cat}

    before do
      visit root_path
      click_on cat.name
    end

    it "autoselect category filter" do
      within '#q_category_id_eq' do
        expect(subject).to have_content(cat.name)
      end
    end
  end

  describe "system" do
    let(:from_account) { create :bank_account, organization: organization, balance: 999 }
    let(:to_account)   { create :bank_account, organization: organization }
    let!(:transfer)    { create :transfer, bank_account_id: from_account.id,
      reference_id: to_account.id }

    let(:another_org)  { create :organization, with_user: user }
    let(:another_from) { create :bank_account, organization: another_org, balance: 999 }
    let(:another_to)   { create :bank_account, organization: another_org }
    let!(:another_transfer) { create :transfer, bank_account_id: another_from.id,
      reference_id: another_to.id }

    let(:category_transfer) { Category.find_by_name(Category::CATEGORY_TRANSFER_INCOME) }
    let(:category_receipt)  { Category.find_by_name(Category::CATEGORY_TRANSFER_OUTCOME) }

    before do
      visit root_path
    end

    describe "Transfer" do
      it_behaves_like 'system category', "Transfer" do
        let(:right_transaction) { transfer.out_transaction }
        let(:wrong_transaction) { another_transfer.out_transaction }
      end
    end

    describe "Receipt" do
      it_behaves_like 'system category', "Receipt" do
        let(:right_transaction) { transfer.inc_transaction }
        let(:wrong_transaction) { another_transfer.inc_transaction }
      end
    end
  end
end
