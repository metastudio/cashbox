# frozen_string_literal: true

require 'rails_helper'

describe 'Filter transactions by ban account' do
  include MoneyHelper

  subject { page }

  let(:user)     { create :user }
  let!(:org)     { create :organization, with_user: user }
  let(:ba)       { create :bank_account, organization: org, balance: Money.from_amount(10_000_000) }

  let(:ba2)           { create :bank_account, organization: org }
  let!(:transaction)  { create :transaction, bank_account: ba }
  let!(:transaction2) { create :transaction, bank_account: ba2 }
  let!(:transaction3) { create :transaction, bank_account: ba2 }
  let!(:transaction4) { create :transaction, bank_account: ba2 }
  let(:correct_items) { [transaction] }
  let(:wrong_items)   { [transaction2, transaction4, transaction3] }

  before do
    sign_in user
    visit root_path
    click_on 'Filters'
    select transaction.bank_account.to_s, from: 'q[bank_account_id_in][]'
    click_on 'Search'
  end

  it_behaves_like 'filterable object'
end
