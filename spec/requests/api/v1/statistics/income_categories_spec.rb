# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/organizations/#/statistics/income_categories' do
  let(:path)    { income_categories_api_organization_statistic_path(org) }
  let(:headers) { auth_header(user) }

  let(:org)  { create :organization, default_currency: 'RUB' }
  let(:user) { create :user, organization: org }

  let!(:income_category1) { create :category, :income,  organization: org, name: 'Category A' }
  let!(:income_category2) { create :category, :income,  organization: org, name: 'Category B' }
  let!(:expense_category) { create :category, :expense, organization: org }

  let(:rub_ba) { create :bank_account, organization: org, currency: 'RUB' }
  let(:usd_ba) { create :bank_account, organization: org, currency: 'USD' }
  let(:eur_ba) { create :bank_account, organization: org, currency: 'EUR' }

  let(:current_month)  { Date.current.beginning_of_month.to_date }
  let(:previous_month) { 1.month.ago.beginning_of_month.to_date }

  let!(:income_category1_transactions) do
    [rub_ba, usd_ba, eur_ba].map do |ba|
      create(:transaction, bank_account: ba, category: income_category1, date: current_month + rand(25), amount: 300_001.99)
    end
  end
  let!(:previous_month_income_transaction) do
    create(:transaction, bank_account: rub_ba, category: income_category1, date: previous_month + rand(25))
  end

  let!(:income_category2_transactions) do
    [rub_ba, usd_ba, eur_ba].map do |ba|
      create(:transaction, bank_account: ba, category: income_category2, date: current_month + rand(25))
    end
  end

  let!(:expense_category_transactions) do
    [rub_ba, usd_ba, eur_ba].map do |ba|
      create(:transaction, bank_account: ba, category: expense_category, date: current_month + rand(25))
    end
  end

  let(:params) { {} }

  before do
    get path, headers: headers, params: params
  end

  it 'returns income categories statistic for current month' do
    expect(response).to be_successful

    statistic_json = json_body.statistic

    expect(statistic_json.data.map(&:to_h)).to eq([
      {
        'name'  => income_category1.name,
        'value' => income_category1_transactions.sum{ |t| t.amount.exchange_to(org.default_currency) }.to_f.round(2),
      },
      {
        'name'  => income_category2.name,
        'value' => income_category2_transactions.sum{ |t| t.amount.exchange_to(org.default_currency) }.to_f.round(2),
      },
    ])

    currency_json = statistic_json.currency
    expect(currency_json.iso_code).to        eq 'RUB'
    expect(currency_json.name).to            eq 'Russian Ruble'
    expect(currency_json.symbol).to          eq '₽'
    expect(currency_json.subunit_to_unit).to eq 100
  end

  context 'if period was provided' do
    let(:params) { { period: 'last-month' } }

    it 'returns income categories statistic for provided period' do
      expect(response).to be_successful

      statistic_json = json_body.statistic

      expect(statistic_json.data.map(&:to_h)).to eq([
        {
          'name'  => income_category1.name,
          'value' => previous_month_income_transaction.amount.exchange_to(org.default_currency).to_f.round(2),
        },
      ])

      currency_json = statistic_json.currency
      expect(currency_json.iso_code).to        eq 'RUB'
      expect(currency_json.name).to            eq 'Russian Ruble'
      expect(currency_json.symbol).to          eq '₽'
      expect(currency_json.subunit_to_unit).to eq 100
    end
  end

  context 'if no data for given preiod' do
    let!(:income_category1_transactions) {}
    let!(:previous_month_income_transaction) {}
    let!(:income_category2_transactions) {}
    let!(:expense_category_transactions) {}

    it 'returns empty data' do
      expect(response).to be_successful

      statistic_json = json_body.statistic

      expect(statistic_json.data).to eq []

      currency_json = statistic_json.currency
      expect(currency_json.iso_code).to        eq 'RUB'
      expect(currency_json.name).to            eq 'Russian Ruble'
      expect(currency_json.symbol).to          eq '₽'
      expect(currency_json.subunit_to_unit).to eq 100
    end
  end

  context 'when not authenticated' do
    let(:headers) { {} }

    it 'returns unauthorized error' do
      expect(response).to(be_unauthorized)
    end
  end

  context 'when authenticated as wrong user' do
    let(:headers) { auth_header(create(:user)) }

    it 'returns 404 error' do
      expect(response).to be_not_found
      expect(json).to be_empty
    end
  end
end
