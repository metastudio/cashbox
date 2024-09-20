# frozen_string_literal: true

require 'rails_helper'

describe 'Filter transactions by period' do
  include MoneyHelper

  subject { page }

  let(:user)    { create :user }
  let!(:org)    { create :organization, with_user: user }
  let(:cat_exp) { create :category, :expense, organization: org }
  let(:ba)      { create :bank_account, organization: org, balance: Money.from_amount(10_000_000) }

  before do
    sign_in user
  end

  context 'when current month is selected' do
    let!(:transaction)  { create :transaction, bank_account: ba }
    let!(:transaction2) { create :transaction, bank_account: ba }
    let!(:transaction3) { create :transaction, bank_account: ba, date: 2.months.ago }
    let!(:transaction4) { create :transaction, bank_account: ba, date: 2.months.ago }
    let!(:transaction5) { create :transaction, bank_account: ba, date: Date.current.end_of_month }
    let!(:transaction6) { create :transaction, bank_account: ba, date: Date.current.beginning_of_month }
    let(:correct_items) { [transaction,  transaction2, transaction5, transaction6] }
    let(:wrong_items)   { [transaction3, transaction4] }

    before do
      visit root_path
      click_on 'Filters'
      select 'Current month', from: 'q[period]'
      click_on 'Search'
    end

    it_behaves_like 'filterable object'
  end

  context 'when last month is selected' do
    let!(:transaction)  { create :transaction, bank_account: ba, date: 1.month.ago }
    let!(:transaction2) { create :transaction, bank_account: ba, date: 1.month.ago }
    let!(:transaction3) { create :transaction, bank_account: ba }
    let!(:transaction4) { create :transaction, bank_account: ba }
    let(:correct_items) { [transaction,  transaction2] }
    let(:wrong_items)   { [transaction3, transaction4] }

    before do
      visit root_path
      click_on 'Filters'
      select 'Last month', from: 'q[period]'
      click_on 'Search'
    end

    it_behaves_like 'filterable object'
  end

  context 'when last 3 months is selected' do
    let!(:transaction)  { create :transaction, bank_account: ba }
    let!(:transaction2) { create :transaction, bank_account: ba, date: 2.months.ago }
    let!(:transaction3) { create :transaction, bank_account: ba, date: 3.months.ago }
    let!(:transaction4) { create :transaction, bank_account: ba, date: 4.months.ago }
    let(:correct_items) { [transaction,  transaction2, transaction3] }
    let(:wrong_items)   { [transaction4] }

    before do
      visit root_path
      click_on 'Filters'
      select 'Last 3 months', from: 'q[period]'
      click_on 'Search'
    end

    it_behaves_like 'filterable object'
  end

  context 'when current quarter is selected' do
    let!(:quarter_start){ Date.current.beginning_of_quarter }
    let!(:transaction)  { create :transaction, bank_account: ba, date: quarter_start }
    let!(:transaction2) { create :transaction, bank_account: ba }
    let!(:transaction3) { create :transaction, bank_account: ba, date: quarter_start - 1.month }
    let!(:transaction4) { create :transaction, bank_account: ba, date: quarter_start - 2.months }
    let(:correct_items) { [transaction,  transaction2] }
    let(:wrong_items)   { [transaction3, transaction4] }

    before do
      visit root_path
      click_on 'Filters'
      select 'Current quarter', from: 'q[period]'
      click_on 'Search'
    end

    it_behaves_like 'filterable object'
  end

  context 'when current year is selected' do
    let!(:year_start)   { Date.current.beginning_of_year }
    let!(:transaction)  { create :transaction, bank_account: ba, date: year_start }
    let!(:transaction2) { create :transaction, bank_account: ba, date: rand(year_start..Date.current) }
    let!(:transaction3) { create :transaction, bank_account: ba, date: rand(year_start..Date.current) }
    let!(:transaction4) { create :transaction, bank_account: ba, date: year_start - 2.years }
    let(:correct_items) { [transaction,  transaction2, transaction3] }
    let(:wrong_items)   { [transaction4] }

    before do
      visit root_path
      click_on 'Filters'
      select 'Current year', from: 'q[period]'
      click_on 'Search'
    end

    it_behaves_like 'filterable object'
  end

  context 'when custom is selected', js: true do
    let!(:transaction)  { create :transaction, bank_account: ba, date: Date.parse('2013-12-12') }
    let!(:transaction2) { create :transaction, bank_account: ba, date: Date.parse('2012-12-12') }
    let!(:transaction3) { create :transaction, bank_account: ba, date: Date.parse('2012-12-20') }
    let!(:transaction4) { create :transaction, bank_account: ba, date: Date.parse('2012-11-20') }
    let(:correct_items) { [transaction2, transaction3] }
    let(:wrong_items)   { [transaction, transaction4] }

    before do
      visit root_path
      click_on 'Filters'
      select 'Custom', from: 'q[period]'
      page.has_content?('To:')
      fill_in 'From:', with: Date.parse('2012-12-10').strftime('%d/%m/%Y')
      fill_in 'To:', with: Date.parse('2012-12-31').strftime('%d/%m/%Y')
      click_on 'Search'
    end

    it_behaves_like 'filterable object'

    context 'and then ordinary', js: true  do
      let(:correct_items) { [transaction4] }
      let(:wrong_items)   { [transaction, transaction2, transaction3] }

      before do
        Timecop.travel(2012, 12, 12)
        select 'Last month', from: 'q[period]'
        click_on 'Search'
      end

      after do
        Timecop.return
      end

      it_behaves_like 'filterable object'
    end

    context 'edge values', js: true do
      let!(:transaction)  { create :transaction, bank_account: ba }
      let!(:transaction2) { create :transaction, bank_account: ba, date: Date.current + 5.days }
      let!(:transaction3) { create :transaction, bank_account: ba, date: Date.current + 10.days }
      let!(:transaction4) { create :transaction, bank_account: ba, date: Date.current - 2.days }
      let(:correct_items) { [transaction2, transaction3] }
      let(:wrong_items)   { [transaction, transaction4] }

      before do
        visit root_path
        click_on 'Filters'
        select 'Custom', from: 'q[period]'
        page.has_content?('To:')
        fill_in 'From:', with: (Date.current + 5.days).strftime('%d/%m/%Y')
        fill_in 'To:', with: (Date.current + 10.days).strftime('%d/%m/%Y')
        click_on 'Search'
      end

      it_behaves_like 'filterable object'
    end
  end
end
