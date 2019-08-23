# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/organizations/#/statistics/balance' do
  let(:path)    { balance_api_organization_statistic_path(org) }
  let(:headers) { auth_header(user) }

  let(:org)  { create :organization, default_currency: 'RUB' }
  let(:user) { create :user, organization: org }

  let(:income_category)  { create :category, :income,  organization: org }
  let(:expense_category) { create :category, :expense, organization: org }

  let(:rub_ba) { create :bank_account, organization: org, currency: 'RUB' }
  let(:usd_ba) { create :bank_account, organization: org, currency: 'USD' }
  let(:eur_ba) { create :bank_account, organization: org, currency: 'EUR' }

  let(:months) { 12.downto(0).map{ |m| (Date.current - m.months).beginning_of_month } }

  let!(:income_transactions) do
    months.each_with_object({}) do |month_beginning, collection|
      collection[month_beginning] = [
        create(:transaction, bank_account: rub_ba, category: income_category, date: month_beginning + rand(25)),
        create(:transaction, bank_account: usd_ba, category: income_category, date: month_beginning + rand(25)),
        create(:transaction, bank_account: eur_ba, category: income_category, date: month_beginning + rand(25)),
      ]
    end
  end

  let!(:expense_transactions) do
    months.each_with_object({}) do |month_beginning, collection|
      collection[month_beginning] = [
        create(:transaction, :expense, bank_account: rub_ba, category: expense_category, date: month_beginning + rand(25)),
        create(:transaction, :expense, bank_account: usd_ba, category: expense_category, date: month_beginning + rand(25)),
        create(:transaction, :expense, bank_account: eur_ba, category: expense_category, date: month_beginning + rand(25)),
      ]
    end
  end

  before do
    get path, headers: headers
  end

  it 'returns balance statistic by months' do
    expect(response).to be_successful

    statistic_json = json_body.statistic

    total = 0
    months.each_with_index do |month_beginning, i|
      month_data_json = statistic_json.data[i]
      month_income  = income_transactions[month_beginning].sum{ |t| t.amount.exchange_to(org.default_currency) }.to_f
      month_expense = expense_transactions[month_beginning].sum{ |t| t.amount.exchange_to(org.default_currency) }.to_f
      total += month_income + month_expense

      expect(month_data_json.month).to   eq month_beginning.strftime('%b, %Y')
      expect(month_data_json.income).to  eq month_income.round(2)
      expect(month_data_json.expense).to eq month_expense.abs.round(2)
      expect(month_data_json.total).to   eq total.round(2)
    end

    currency_json = statistic_json.currency
    expect(currency_json.iso_code).to        eq 'RUB'
    expect(currency_json.name).to            eq 'Russian Ruble'
    expect(currency_json.symbol).to          eq '₽'
    expect(currency_json.subunit_to_unit).to eq 100

    pagination_json = json_body.pagination
    expect(pagination_json.current).to  eq 0
    expect(pagination_json.next).to     eq 1
    expect(pagination_json.previous).to eq nil
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
