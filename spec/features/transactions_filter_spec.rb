require 'spec_helper'

describe 'Transactions filter' do
  include MoneyHelper

  let(:user) { create :user, :with_organizations }
  let(:org)  { user.organizations.first }
  let(:ba)   { create :bank_account, organization: org }

  before do
    sign_in user
  end

  subject { page }

  context "filter by amount" do
    let!(:transaction)  { create :transaction, bank_account: ba, amount: 100123.23 }
    let!(:transaction2) { create :transaction, bank_account: ba, amount: 100123.23 }
    let!(:transaction3) { create :transaction, bank_account: ba, amount: 300 }
    let!(:transaction4) { create :transaction, bank_account: ba, amount: 600 }
    let(:correct_items) { [transaction,  transaction2] }
    let(:wrong_items)   { [transaction3, transaction4] }

    before do
      visit root_path
      fill_in 'q[amount_eq]', with: "100,123.23"
      click_on 'Search'
    end

    it_behaves_like 'filterable object'
  end

  context "filter by comment" do
    let!(:transaction)  { create :transaction, bank_account: ba, comment: 'Comment' }
    let!(:transaction2) { create :transaction, bank_account: ba, comment: 'Another text' }
    let!(:transaction3) { create :transaction, bank_account: ba, comment: 'Comment' }
    let!(:transaction4) { create :transaction, bank_account: ba, comment: 'Other text' }
    let(:correct_items) { [transaction,  transaction3] }
    let(:wrong_items)   { [transaction2, transaction4] }

    before do
      visit root_path
      fill_in 'q[comment_cont]', with: 'Comment'
      click_on 'Search'
    end

    it_behaves_like 'filterable object'
  end

  context "filter by amount & comment" do
    let!(:transaction)  { create :transaction, bank_account: ba, amount: 100,
      comment: "Comment to find" }
    let!(:transaction2) { create :transaction, bank_account: ba, amount: 100,
      comment: "Text" }
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

  context "filter by date" do
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
      let!(:transaction2) { Timecop.travel(quarter_start + 1.month) {
        create :transaction, bank_account: ba } }
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
      let!(:transaction2) { Timecop.travel(rand(year_start..Time.now.end_of_year)) {
        create :transaction, bank_account: ba } }
      let!(:transaction3) { Timecop.travel(rand(year_start..Time.now.end_of_year)) {
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

  context "filter by amount, comment, and date" do
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
end
