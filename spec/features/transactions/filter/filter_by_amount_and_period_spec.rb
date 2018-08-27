# frozen_string_literal: true

require 'rails_helper'

describe 'Filter transactions by amount and period' do
  subject { page }

  let(:org)  { create :organization }
  let(:user) { create :user, organization: org }
  let(:ba)   { create :bank_account, organization: org, balance: Money.from_amount(10_000_000) }

  let!(:transaction)  { create :transaction, bank_account: ba, amount: 100, date: 1.month.ago }
  let!(:transaction2) { create :transaction, bank_account: ba, amount: 100, date: Date.current }
  let!(:transaction3) { create :transaction, bank_account: ba, amount: 100, date: 2.months.ago }
  let!(:transaction4) { create :transaction, bank_account: ba, amount: 500, date: 6.months.ago }

  let(:correct_items) { [transaction] }
  let(:wrong_items)   { [transaction3, transaction2, transaction4] }

  before do
    sign_in user
    visit root_path

    click_on 'Filters'
    within 'form#transaction_search' do
      fill_in 'q[amount_eq]', with: 100
      select 'Last month', from: 'q[period]'
      click_on 'Search'
    end
  end

  it_behaves_like 'filterable object'
end
