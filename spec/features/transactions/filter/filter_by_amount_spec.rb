# frozen_string_literal: true

require 'rails_helper'

describe 'Filter transactions by amount' do
  include MoneyHelper

  subject { page }

  let(:user)     { create :user }
  let!(:org)     { create :organization, with_user: user }
  let(:cat_exp)  { create :category, :expense, organization: org }
  let(:ba)       { create :bank_account, organization: org, balance: Money.from_amount(10_000_000) }

  let!(:transaction)  { create :transaction, bank_account: ba, amount: Money.from_amount(100_123.23) }
  let!(:transaction2) { create :transaction, bank_account: ba, amount: Money.from_amount(100_123.23), category: cat_exp }
  let!(:transaction3) { create :transaction, bank_account: ba, amount: Money.from_amount(300) }
  let!(:transaction4) { create :transaction, bank_account: ba, amount: Money.from_amount(5000) }

  let(:correct_items) { [transaction,  transaction2] }
  let(:wrong_items)   { [transaction3, transaction4] }

  let(:amount_eq)     { 100_123.23 }

  before do
    sign_in user
    visit root_path

    click_on 'Filter'
    within 'form#transaction_search' do
      fill_in 'q[amount_eq]', with: amount_eq
      click_on 'Search'
    end
  end

  it_behaves_like 'filterable object'

  context 'when amount is too long' do
    let(:amount_eq) { '1' * 1610 }

    it 'doesn\'t break' do
      is_expected.to have_content 'There is nothing found'
    end
  end

  context 'amount is maximum value' do
    let(:amount_eq)    { Dictionaries.money_max }
    let!(:bac)         { create :bank_account, organization: org }
    let!(:transaction) { create :transaction, bank_account: bac, amount: amount_eq }

    it 'show relevant transaction' do
      is_expected.to have_content(money_with_symbol(transaction.amount))
    end
  end
end
