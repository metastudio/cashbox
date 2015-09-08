require 'spec_helper'

describe 'Transactions filter' do
  include MoneyHelper

  let(:user)     { create :user }
  let!(:org)     { create :organization, with_user: user }
  let(:cat_exp)  { create :category, :expense, organization: org }
  let(:ba)       { create :bank_account, organization: org, balance: 10000000 }
  let(:def_curr ){ org.default_currency }

  before do
    sign_in user
  end

  subject { page }

  context "by amount", js: true do
    let!(:transaction)  { create :transaction, bank_account: ba, amount: 100123.23 }
    let!(:transaction2) { create :transaction, bank_account: ba, amount: 100123.23,
      category: cat_exp }
    let!(:transaction3) { create :transaction, bank_account: ba, amount: 300 }
    let!(:transaction4) { create :transaction, bank_account: ba, amount: 5000 }
    let(:correct_items) { [transaction,  transaction2] }
    let(:wrong_items)   { [transaction3, transaction4] }
    let(:amount_eq)     { 100123.23 }

    before do
      visit root_path
      fill_in 'q[amount_eq]', with: amount_eq
      click_on 'Search'
    end

    it_behaves_like 'filterable object'

    context 'when too long' do
      let(:amount_eq) { '1' * 1610  }
      it 'doesnt break' do
        expect(subject).to have_content 'There is nothing found'
      end
    end

    context 'max' do
      let(:amount_eq)    { Dictionaries.money_max }
      let!(:bac)         { create :bank_account, organization: org }
      let!(:transaction) { create :transaction, bank_account: bac, amount: amount_eq }

      it 'show relevant transaction' do
        expect(subject).to have_content(money_with_symbol(transaction.amount))
      end
    end
  end

  context "by comment" do
    let!(:transaction)  { create :transaction, bank_account: ba, comment: 'Comment' }
    let!(:transaction2) { create :transaction, bank_account: ba, comment: 'Another text' }
    let!(:transaction3) { create :transaction, bank_account: ba, comment: 'Comment' }
    let!(:transaction4) { create :transaction, bank_account: ba, comment: 'Other text' }
    let(:correct_items) { [transaction,  transaction3] }
    let(:wrong_items)   { [transaction2, transaction4] }
    let(:comment_cont)  { 'Comment' }

    before do
      visit root_path
      fill_in 'q[comment_cont]', with: comment_cont
      click_on 'Search'
    end

    it_behaves_like 'filterable object'

    context 'when too long' do
      let(:comment_cont) { 'a' * 1610 }
      it 'doesnt break' do
        expect(subject).to have_content 'There is nothing found'
      end
    end
  end

  context 'by category' do
    let!(:transfer) { create :transfer }

    before do
      visit root_path
    end

    it 'show system categories' do
      within '#q_category_id_in' do
        expect(page).to have_content(Category::CATEGORY_TRANSFER_INCOME)
      end
    end

    context 'apply' do
      let(:cat2)  { create :category, organization: org }
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
    end
  end

  context 'by bank_account' do
    let(:ba2)           { create :bank_account, organization: org }
    let!(:transaction)  { create :transaction, bank_account: ba }
    let!(:transaction2) { create :transaction, bank_account: ba2 }
    let!(:transaction3) { create :transaction, bank_account: ba2 }
    let!(:transaction4) { create :transaction, bank_account: ba2 }
    let(:correct_items) { [transaction] }
    let(:wrong_items)   { [transaction2, transaction4, transaction3] }

    before do
      visit root_path
      select transaction.bank_account.to_s, from: 'q[bank_account_id_in][]'
      click_on 'Search'
    end

    it_behaves_like 'filterable object'
  end

  context "by amount & comment" do
    let!(:transaction)  { create :transaction, bank_account: ba, amount: 100,
      comment: "Comment to find" }
    let!(:transaction2) { create :transaction, bank_account: ba, amount: 100,
      comment: "Text", category: cat_exp }
    let!(:transaction3) { create :transaction, bank_account: ba, amount: 300,
      comment: "Another text"}
    let!(:transaction4) { create :transaction, bank_account: ba, amount: 600,
      comment: "Comment is right, but amount is not" }
    let(:correct_items) { [transaction] }
    let(:wrong_items)   { [transaction2, transaction4, transaction3] }

    before do
      visit root_path
      fill_in 'q[amount_eq]', with: 100
      fill_in 'q[comment_cont]', with: 'Comment'
      click_on 'Search'
    end

    it_behaves_like 'filterable object'
  end

  context "by date" do
    context "when current month" do
      let!(:transaction)  { create :transaction, bank_account: ba }
      let!(:transaction2) { create :transaction, bank_account: ba }
      let!(:transaction3) { Timecop.travel(2.month.ago) {
        create :transaction, bank_account: ba } }
      let!(:transaction4) { Timecop.travel(2.month.ago) {
        create :transaction, bank_account: ba } }
      let(:correct_items) { [transaction,  transaction2] }
      let(:wrong_items)   { [transaction3, transaction4] }

      before do
        visit root_path
        select 'Current month', from: 'q[period]'
        click_on 'Search'
      end

      it_behaves_like 'filterable object'
    end

    context "when previous month" do
      let!(:transaction)  { Timecop.travel(1.month.ago) {
        create :transaction, bank_account: ba } }
      let!(:transaction2) { Timecop.travel(1.month.ago) {
        create :transaction, bank_account: ba } }
      let!(:transaction3) { create :transaction, bank_account: ba }
      let!(:transaction4) { create :transaction, bank_account: ba }
      let(:correct_items) { [transaction,  transaction2] }
      let(:wrong_items)   { [transaction3, transaction4] }

      before do
        visit root_path
        select 'Previous month', from: 'q[period]'
        click_on 'Search'
      end

      it_behaves_like 'filterable object'
    end

    context "when last 3 months" do
      let!(:transaction)  { create :transaction, bank_account: ba }
      let!(:transaction2) { Timecop.travel(2.month.ago) {
        create :transaction, bank_account: ba } }
      let!(:transaction3) { Timecop.travel(3.month.ago) {
        create :transaction, bank_account: ba } }
      let!(:transaction4) { Timecop.travel(4.month.ago) {
        create :transaction, bank_account: ba } }
      let(:correct_items) { [transaction,  transaction2, transaction3] }
      let(:wrong_items)   { [transaction4] }

      before do
        visit root_path
        select 'Last 3 months', from: 'q[period]'
        click_on 'Search'
      end

      it_behaves_like 'filterable object'
    end

    context "when last quarter" do
      let!(:quarter_start){ Time.now.beginning_of_quarter }
      let!(:transaction)  { Timecop.travel(quarter_start) {
        create :transaction, bank_account: ba } }
      let!(:transaction2) { create :transaction, bank_account: ba }
      let!(:transaction3) { Timecop.travel(quarter_start - 1.month) {
        create :transaction, bank_account: ba } }
      let!(:transaction4) { Timecop.travel(quarter_start - 2.month) {
        create :transaction, bank_account: ba } }
      let(:correct_items) { [transaction,  transaction2] }
      let(:wrong_items)   { [transaction3, transaction4] }

      before do
        visit root_path
        select 'Quarter', from: 'q[period]'
        click_on 'Search'
      end

      it_behaves_like 'filterable object'
    end

    context "when last year" do
      let!(:year_start)   { Time.now.beginning_of_year }
      let!(:transaction)  { Timecop.travel(year_start) {
        create :transaction, bank_account: ba } }
      let!(:transaction2) { Timecop.travel(rand(year_start..Time.now)) {
        create :transaction, bank_account: ba } }
      let!(:transaction3) { Timecop.travel(rand(year_start..Time.now)) {
        create :transaction, bank_account: ba } }
      let!(:transaction4) { Timecop.travel(year_start - 2.year) {
        create :transaction, bank_account: ba } }
      let(:correct_items) { [transaction,  transaction2, transaction3] }
      let(:wrong_items)   { [transaction4] }

      before do
        visit root_path
        select 'This year', from: 'q[period]'
        click_on 'Search'
      end

      it_behaves_like 'filterable object'
    end

    context 'when custom' do
      let!(:transaction)  { Timecop.travel(2013,12,12) {
        create :transaction, bank_account: ba } }
      let!(:transaction2) { Timecop.travel(2012,12,12) {
        create :transaction, bank_account: ba } }
      let!(:transaction3) { Timecop.travel(2012,12,20) {
        create :transaction, bank_account: ba } }
      let!(:transaction4) { Timecop.travel(2012,11,20) {
        create :transaction, bank_account: ba } }
      let(:correct_items) { [transaction2,  transaction3] }
      let(:wrong_items)   { [transaction, transaction4] }

      before do
        visit root_path
        select 'Custom', from: 'q[period]'
        page.has_content?('To:')
        fill_in 'From:', with: (Time.new(2012,12,10)).strftime('%d/%m/%Y')
        fill_in 'To:', with: (Time.new(2012,12,31)).strftime('%d/%m/%Y')
        click_on 'Search'
      end

      it_behaves_like 'filterable object'

      context 'and then ordinary', js: true  do
        let(:correct_items) { [transaction4] }
        let(:wrong_items)   { [transaction, transaction2, transaction3] }

        before do
          Timecop.travel(2012,12,12)
          select 'Previous month', from: 'q[period]'
          click_on 'Search'
        end

        after do
          Timecop.return
        end

        it_behaves_like 'filterable object'
      end

      context 'edge values' do
        let!(:transaction)  { create :transaction, bank_account: ba }
        let!(:transaction2) { Timecop.travel( Time.now + 5.days) {
          create :transaction, bank_account: ba } }
        let!(:transaction3) { Timecop.travel( Time.now + 10.days) {
          create :transaction, bank_account: ba } }
        let!(:transaction4) { Timecop.travel( Time.now - 2.day) {
          create :transaction, bank_account: ba } }
        let(:correct_items) { [transaction2, transaction3] }
        let(:wrong_items)   { [transaction, transaction4] }

        before do
          visit root_path
          select 'Custom', from: 'q[period]'
          page.has_content?('To:')
          fill_in 'From:', with: (Time.now + 5.days).strftime('%d/%m/%Y')
          fill_in 'To:', with: (Time.now + 10.days).strftime('%d/%m/%Y')
          click_on 'Search'
        end

        it_behaves_like 'filterable object'
      end
    end
  end

  context "by amount, comment, and date" do
    let!(:transaction)  { Timecop.travel(1.month.ago) {
      create :transaction, bank_account: ba, amount: 100, comment: "Comment" }}
    let!(:transaction2) { create :transaction, bank_account: ba, amount: 100,
      comment: "Text" }
    let!(:transaction3) { Timecop.travel(2.month.ago) {
      create :transaction, bank_account: ba, amount: 100, comment: "Comment" } }
    let!(:transaction4) { Timecop.travel(6.month.ago) {
      create :transaction, bank_account: ba, amount: 500, comment: "Comment" } }
    let(:correct_items) { [transaction] }
    let(:wrong_items)   { [transaction3, transaction2, transaction4] }

    before do
      visit root_path
      fill_in 'q[amount_eq]', with: 100
      select 'Previous month', from: 'q[period]'
      click_on 'Search'
    end

    it_behaves_like 'filterable object'
  end

  context 'memorized' do
    let(:ba2)           { create :bank_account, organization: org }
    let!(:transaction)  { create :transaction, bank_account: ba }
    let!(:transaction2) { create :transaction, bank_account: ba2 }
    let!(:transaction3) { create :transaction, bank_account: ba2 }
    let!(:transaction4) { create :transaction, bank_account: ba2 }
    let(:correct_items) { [transaction2] }
    let(:wrong_items)   { [transaction, transaction4, transaction3] }

    before do
      visit root_path
      within "#transaction_#{transaction2.id}" do
        click_on transaction2.bank_account.name
        click_on transaction2.category.name
      end
    end

    it_behaves_like 'filterable object'
  end

  context 'clear btn', js: true do
    let!(:cat)  { create :category, organization: org }
    let!(:cust) { create :customer, organization: org }
    let!(:ba)   { create :bank_account, organization: org }

    before do
      visit root_path
      fill_in 'q[amount_eq]', with: "9999"
      fill_in 'q[comment_cont]', with: 'Comment'
      select2(cat.name, css: '#s2id_q_category_id_in')
      select2(cust.to_s, css: '#s2id_q_customer_id_in')
      select2(ba.to_s, css: '#s2id_q_bank_account_id_in')
      select 'Current month', from: 'q[period]'
      click_on 'Clear'
    end

    it 'should completely clear form' do
      within '#transaction_search' do
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
    context 'when uncategorized transactions shown' do
      let!(:ba)   { create :bank_account, organization: org, residue: 100 }
      let(:amount){ money_with_symbol Money.empty(org.default_currency) }
      before do
        visit root_path
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
  end
end
