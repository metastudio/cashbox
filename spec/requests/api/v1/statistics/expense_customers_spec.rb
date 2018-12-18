# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/organizations/#/statistics/expense_customers' do
  let(:path)    { expense_customers_api_organization_statistic_path(org) }
  let(:headers) { auth_header(user) }

  let(:org)  { create :organization, default_currency: 'RUB' }
  let(:user) { create :user, organization: org }

  let(:inc_category) { create :category, :income,  organization: org }
  let(:exp_category) { create :category, :expense, organization: org }

  let!(:customer1)    { create :customer, organization: org }
  let!(:customer2)    { create :customer, organization: org }
  let!(:inc_customer) { create :customer, organization: org }

  let(:rub_ba) { create :bank_account, organization: org, currency: 'RUB' }
  let(:usd_ba) { create :bank_account, organization: org, currency: 'USD' }
  let(:eur_ba) { create :bank_account, organization: org, currency: 'EUR' }

  let(:current_month)  { Date.current.beginning_of_month.to_date }
  let(:previous_month) { 1.month.ago.beginning_of_month.to_date }

  let!(:customer1_exp_transaction1)   { create(:transaction, customer: customer1,    bank_account: rub_ba, category: exp_category, date: current_month + rand(25)) }
  let!(:customer1_exp_transaction2)   { create(:transaction, customer: customer1,    bank_account: usd_ba, category: exp_category, date: current_month + rand(25)) }
  let!(:customer1_exp_transaction3)   { create(:transaction, customer: customer1,    bank_account: rub_ba, category: exp_category, date: previous_month + rand(25)) }
  let!(:customer2_exp_transaction1)   { create(:transaction, customer: customer2,    bank_account: usd_ba, category: exp_category, date: current_month + rand(25)) }
  let!(:customer2_exp_transaction2)   { create(:transaction, customer: customer2,    bank_account: eur_ba, category: exp_category, date: current_month + rand(25)) }
  let!(:customer2_inc_transaction)    { create(:transaction, customer: customer2,    bank_account: eur_ba, category: inc_category, date: current_month + rand(25)) }
  let!(:inc_customer_inc_transaction) { create(:transaction, customer: inc_customer, bank_account: rub_ba, category: inc_category, date: current_month + rand(25)) }

  let(:customer1_transactions) { [customer1_exp_transaction1, customer1_exp_transaction2] }
  let(:customer2_transactions) { [customer2_exp_transaction1, customer2_exp_transaction2] }

  let(:params) { {} }

  before do
    get path, headers: headers, params: params
  end

  it 'returns expense customer statistic for current month' do
    expect(response).to be_success

    statistic_json = json_body.statistic

    expect(statistic_json.data.map(&:to_h)).to eq([
      {
        'name'  => customer2.name,
        'value' => customer2_transactions.sum{ |t| t.amount.exchange_to(org.default_currency) }.to_f.round(2).abs,
      },
      {
        'name'  => customer1.name,
        'value' => customer1_transactions.sum{ |t| t.amount.exchange_to(org.default_currency) }.to_f.round(2).abs,
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
      expect(response).to be_success

      statistic_json = json_body.statistic

      expect(statistic_json.data.map(&:to_h)).to eq([
        {
          'name'  => customer1.name,
          'value' => customer1_exp_transaction3.amount.exchange_to(org.default_currency).to_f.round(2).abs,
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
    let!(:customer1_exp_transaction1)   {}
    let!(:customer1_exp_transaction2)   {}
    let!(:customer1_exp_transaction3)   {}
    let!(:customer2_exp_transaction1)   {}
    let!(:customer2_exp_transaction2)   {}
    let!(:customer2_inc_transaction)    {}
    let!(:inc_customer_inc_transaction) {}

    it 'returns empty data' do
      expect(response).to be_success

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
