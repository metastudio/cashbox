# frozen_string_literal: true

require 'rails_helper'

describe 'Filter transactions' do
  include MoneyHelper

  subject { page }

  let(:org)  { create :organization }
  let(:user) { create :user, organization: org }
  let(:ba)   { create :bank_account, organization: org, balance: Money.from_amount(10_000_000) }

  before do
    sign_in user
  end

  describe 'via links' do
    let(:ba2)           { create :bank_account, organization: org }
    let!(:transaction)  { create :transaction, bank_account: ba }
    let!(:transaction2) { create :transaction, bank_account: ba2 }
    let!(:transaction3) { create :transaction, bank_account: ba2 }
    let!(:transaction4) { create :transaction, bank_account: ba2 }
    let(:correct_items) { [transaction2] }
    let(:wrong_items)   { [transaction, transaction4, transaction3] }

    before do
      visit root_path

      click_on 'Filters'
      within "#transaction_#{transaction2.id}" do
        click_on transaction2.bank_account.name
        click_on transaction2.category.name
      end
    end

    it_behaves_like 'filterable object'
  end

  describe 'clear button', js: true do
    let!(:cat)  { create :category, organization: org }
    let!(:cust) { create :customer, organization: org }
    let!(:ba)   { create :bank_account, organization: org }

    before do
      visit root_path

      click_on 'Filters'
      within 'form#transaction_search' do
        fill_in 'q[amount_eq]', with: '9999'
        fill_in 'q[comment_cont]', with: 'Comment'
        select2(cat.name, css: '#s2id_q_category_id_in')
        select2(cust.to_s, css: '#s2id_q_customer_id_in')
        select2(ba.to_s, css: '#s2id_q_bank_account_id_in')
        select 'Current month', from: 'q[period]'
        click_on 'Clear'
      end
    end

    it 'clears form' do
      within 'form#transaction_search' do
        expect(page).to have_css('#q_amount_eq', text: '')
        expect(page).to have_css('#q_comment_cont', text: '')
        expect(page).to have_css('#s2id_q_category_id_in', text: '')
        expect(page).to have_css('#s2id_q_customer_id_in', text: '')
        expect(page).to have_css('#s2id_q_bank_account_id_in', text: '')
        expect(page).to have_css('#q_period', text: '')
      end
    end
  end

  context 'flow' do
    context 'when uncategorized transactions shown', js: true do
      let!(:ba)   { create :bank_account, organization: org, residue: 100 }
      let(:amount){ money_with_symbol Money.empty(org.default_currency) }

      before do
        visit root_path
        click_on 'Filters'
        within '.accounts' do
          click_link ba.to_s
        end
      end

      it 'display nil flow' do
        within '#flow' do
          expect(page).to have_content("Income: #{amount}")
          expect(page).to have_content("Expense: #{amount}")
          expect(page).to have_content("Total: #{amount}")
        end
      end
    end

    context 'should display without transfers amounts', js: true do
      let!(:transaction) { create :transaction, :income, bank_account: ba, organization: org }
      let(:amount)       { money_with_symbol Money.new(transaction.amount, org.default_currency) }
      let!(:transfer)    { create :transfer, :with_different_currencies, bank_account_id: ba.id }

      before do
        visit root_path
        click_on 'Filters'
        within "##{dom_id(transaction)}" do
          click_link ba.to_s
        end
      end

      it 'display correct total amount' do
        within '#flow' do
          expect(page).to have_content("Total: #{amount}")
        end
      end
    end
  end

  describe 'GET #transactions.csv' do
    let!(:transaction)  { create :transaction, bank_account: ba, date: Date.current.end_of_month }

    before do
      visit root_path
      click_on 'Filters'
      within 'form#transaction_search' do
        select 'Current month', from: 'q[period]'
        click_on 'Search'
      end
    end

    it 'has link to export select transactions in csv format' do
      expect(page).to have_link('Download as .CSV')
      click_link 'Download as .CSV'
      expect(page.response_headers['Content-Type']).to eq 'text/csv'
      expect(page.body).to eq <<~CSV
          Date;Currency;Amount (negative for outcome, positive for income);Category;Customer name;Bank account;Comment
          #{transaction.date};#{transaction.currency};#{transaction.amount};#{transaction.category};#{transaction.customer_name};#{transaction.bank_account};#{transaction.comment}
        CSV
    end
  end
end
