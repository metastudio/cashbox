# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/organizations/#/statistics/income_customers_by_months' do
  let(:path)    { income_customers_by_months_api_organization_statistic_path(org) }
  let(:headers) { auth_header(user) }

  let!(:org)  { create :organization, default_currency: 'RUB' }
  let(:user) { create :user, organization: org }

  let!(:income_category)  { create :category, :income,  organization: org }
  let!(:expense_category) { create :category, :expense, organization: org }

  let!(:customer1) { create :customer, organization: org, name: 'Customer A' }
  let!(:customer2) { create :customer, organization: org, name: 'Customer B' }

  let!(:rub_ba) { create :bank_account, organization: org, currency: 'RUB' }
  let!(:usd_ba) { create :bank_account, organization: org, currency: 'USD' }
  let!(:eur_ba) { create :bank_account, organization: org, currency: 'EUR' }

  let(:months) { 12.downto(0).map{ |m| (Date.current - m.months).beginning_of_month } }

  let!(:c1_income_transactions) do
    months.each_with_object({}) do |month_beginning, collection|
      collection[month_beginning] = [
        create(:transaction, bank_account: rub_ba, customer: customer1, category: income_category, date: month_beginning + rand(25)),
        create(:transaction, bank_account: usd_ba, customer: customer1, category: income_category, date: month_beginning + rand(25)),
        create(:transaction, bank_account: eur_ba, customer: customer1, category: income_category, date: month_beginning + rand(25)),
      ]
    end
  end

  let!(:c2_income_transactions) do
    months.each_with_object({}) do |month_beginning, collection|
      collection[month_beginning] = [
        create(:transaction, bank_account: rub_ba, customer: customer2, category: income_category, date: month_beginning + rand(25)),
        create(:transaction, bank_account: usd_ba, customer: customer2, category: income_category, date: month_beginning + rand(25)),
        create(:transaction, bank_account: eur_ba, customer: customer2, category: income_category, date: month_beginning + rand(25)),
      ]
    end
  end

  before do
    get path, headers: headers
  end

  it 'returns income customers statistic by months' do
    expect(response).to be_success

    statistic_json = json_body.statistic

    header = statistic_json.header
    expect(header).to include customer1.name
    expect(header).to include customer2.name

    months.each_with_index do |month_beginning, i|
      month_data_json = statistic_json.data[i]
      c1_month_income  = c1_income_transactions[month_beginning].sum{ |t| t.amount.exchange_to(org.default_currency) }.to_f.round(2)
      c2_month_income  = c2_income_transactions[month_beginning].sum{ |t| t.amount.exchange_to(org.default_currency) }.to_f.round(2)

      expect(month_data_json.month).to eq month_beginning.strftime('%b, %Y')
      expect(month_data_json).to       include customer1.name => c1_month_income
      expect(month_data_json).to       include customer2.name => c2_month_income
    end

    currency_json = statistic_json.currency
    expect(currency_json.iso_code).to        eq 'RUB'
    expect(currency_json.name).to            eq 'Russian Ruble'
    expect(currency_json.symbol).to          eq '₽'
    expect(currency_json.subunit_to_unit).to eq 100
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
