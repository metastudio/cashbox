require 'spec_helper'

describe 'category page' do
  let(:user)          { create :user }
  let(:org)           { create :organization, with_user: user }
  let!(:account)      { create :bank_account, organization: org }
  let(:account_name)  { account.name }

  before do
    sign_in user
  end

  subject{ page }

  it_behaves_like "paginateable" do
    let(:paginated)        { 10 }
    let(:categories_count) { paginated + 10 }
    let!(:list)    { FactoryGirl.create_list(:category, categories_count,
      organization: org).reverse }
    let(:list_class)     { ".categories" }
    let(:list_page)      { categories_path }
    let(:item_id_prefix) { "#category_"}
  end

  describe 'when opened via transactions table column' do
    let(:cat)          { create :category, organization: org }
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

    it "is root_path now" do
      expect(current_path).to eq root_path
    end
  end

  describe "system" do
    let(:from_account) { create :bank_account, organization: org, balance: 999 }
    let(:to_account)   { create :bank_account, organization: org }
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
