# frozen_string_literal: true

require 'rails_helper'

describe 'Filter transactions by comment' do
  include MoneyHelper

  subject { page }

  let(:user)     { create :user }
  let!(:org)     { create :organization, with_user: user }
  let(:ba)       { create :bank_account, organization: org, balance: Money.from_amount(10_000_000) }

  let!(:transaction)  { create :transaction, bank_account: ba, comment: 'Comment' }
  let!(:transaction2) { create :transaction, bank_account: ba, comment: 'Another text' }
  let!(:transaction3) { create :transaction, bank_account: ba, comment: 'Comment' }
  let!(:transaction4) { create :transaction, bank_account: ba, comment: 'Other text' }
  let(:correct_items) { [transaction,  transaction3] }
  let(:wrong_items)   { [transaction2, transaction4] }
  let(:comment_cont)  { 'Comment' }

  before do
    sign_in user
    visit root_path
    click_on 'Filters'
    fill_in 'q[comment_cont]', with: comment_cont
    click_on 'Search'
  end

  it_behaves_like 'filterable object'

  context 'when too long' do
    let(:comment_cont) { 'a' * 1610 }
    it 'doesn\'t break' do
      expect(subject).to have_content 'There is nothing found'
    end
  end
end
