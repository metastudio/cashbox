# frozen_string_literal: true

require 'rails_helper'

describe 'Filter transactions by category' do
  include MoneyHelper

  subject { page }

  let(:user)     { create :user }
  let!(:org)     { create :organization, with_user: user }
  let(:cat_exp)  { create :category, :expense, organization: org }
  let(:ba)       { create :bank_account, organization: org, balance: Money.from_amount(10_000_000) }

  let!(:transfer) { create :transfer }

  before do
    sign_in user
    visit root_path
    click_on 'Filters'
  end

  it 'shows system categories' do
    within '#q_category_id_in' do
      expect(page).to have_content(Category::CATEGORY_TRANSFER_INCOME)
    end
  end

  context 'apply' do
    let(:cat2) { create :category, organization: org }

    let!(:transaction)  { create :transaction, bank_account: ba, category: cat_exp }
    let!(:transaction2) { create :transaction, bank_account: ba, category: cat2 }
    let!(:transaction3) { create :transaction, bank_account: ba, category: cat2 }
    let!(:transaction4) { create :transaction, bank_account: ba, category: cat2 }

    let(:correct_items) { [transaction] }
    let(:wrong_items)   { [transaction2, transaction4, transaction3] }

    before do
      visit root_path
      select transaction.category.name, from: 'q[category_id_in][]'
      click_on 'Search'
    end

    it_behaves_like 'filterable object'

    it 'generates valid links' do
      within "#transaction_#{transaction.id}" do
        click_link cat_exp.name
      end

      expect(current_path).to eq root_path
    end
  end
end
