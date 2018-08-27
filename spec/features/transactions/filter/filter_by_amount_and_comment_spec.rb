# frozen_string_literal: true

require 'rails_helper'

describe 'Filter transactions by amount and comment' do
  include MoneyHelper

  subject { page }

  let(:org)     { create :organization }
  let(:user)    { create :user, organization: org }
  let(:ba)      { create :bank_account, organization: org, balance: Money.from_amount(10_000_000) }
  let(:cat_exp) { create :category, :expense, organization: org }

  let!(:transaction)  { create :transaction, bank_account: ba, amount: 100, comment: 'Comment to find' }
  let!(:transaction2) { create :transaction, bank_account: ba, amount: 100, comment: 'Text', category: cat_exp }
  let!(:transaction3) { create :transaction, bank_account: ba, amount: 300, comment: 'Another text' }
  let!(:transaction4) { create :transaction, bank_account: ba, amount: 600, comment: 'Comment is right, but amount is not' }

  let(:correct_items) { [transaction] }
  let(:wrong_items)   { [transaction2, transaction4, transaction3] }

  before do
    sign_in user
    visit root_path

    click_on 'Filters'
    within 'form#transaction_search' do
      fill_in 'q[amount_eq]', with: 100
      fill_in 'q[comment_cont]', with: 'Comment'
      click_on 'Search'
    end
  end

  it_behaves_like 'filterable object'
end
