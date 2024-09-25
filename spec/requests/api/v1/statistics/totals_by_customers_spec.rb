# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/organizations/#/statistics/totals_by_customers' do
  let(:path)    { totals_by_customers_api_organization_statistic_path(org) }
  let(:headers) { auth_header(user) }

  let(:org)  { create :organization, default_currency: 'RUB' }
  let(:user) { create :user, organization: org }

  let!(:customer1)    { create :customer, organization: org, name: 'Customer A' }
  let!(:customer2)    { create :customer, organization: org, name: 'Customer B' }

  let!(:inc_category) { create :category, :income,  organization: org }
  let!(:exp_category) { create :category, :expense, organization: org }

  let(:rub_ba) { create :bank_account, organization: org, currency: 'RUB' }
  let(:usd_ba) { create :bank_account, organization: org, currency: 'USD' }
  let(:eur_ba) { create :bank_account, organization: org, currency: 'EUR' }

  let(:current_month)  { Date.current.beginning_of_month.to_date }
  let(:previous_month) { 1.month.ago.beginning_of_month.to_date }

  let!(:invoice1) do
    create :invoice, customer_name: customer1.name, organization: org, ends_at: current_month, currency: 'RUB'
  end
  let!(:i1_invoice_item1) do
    create :invoice_item, invoice: invoice1, customer_name: customer1.name, date: current_month, amount: 300_001.99, currency: 'RUB'
  end
  let!(:i1_invoice_item2) do
    create :invoice_item, invoice: invoice1, customer_name: customer1.name, date: current_month, amount: 100, currency: 'RUB'
  end
  let!(:i1_invoice_item3) do
    create :invoice_item, invoice: invoice1, customer_name: customer1.name, date: previous_month, amount: 300, currency: 'RUB'
  end

  let!(:invoice2) do
    create :invoice, customer_name: customer2.name, organization: org, ends_at: current_month, currency: 'USD'
  end
  let!(:i2_invoice_item1) do
    create :invoice_item, invoice: invoice2, customer_name: customer2.name, date: current_month, amount: 5
  end
  let!(:i2_invoice_item2) do
    create :invoice_item, invoice: invoice2, customer_name: customer2.name, date: current_month, amount: 1
  end
  let!(:i2_invoice_item3) do
    create :invoice_item, invoice: invoice2, customer_name: customer2.name, date: previous_month, amount: 3
  end

  let!(:customer1_transaction1) do
    create(:transaction, customer: customer1, bank_account: rub_ba, category: exp_category, date: current_month)
  end
  let!(:customer1_transaction2) do
    create(:transaction, customer: customer1, bank_account: usd_ba, category: inc_category, date: previous_month)
  end
  let!(:customer2_transaction1) do
    create(:transaction, customer: customer2, bank_account: usd_ba, category: inc_category, date: current_month)
  end

  let(:customer1_items) { [i1_invoice_item1, i1_invoice_item2, customer1_transaction1] }
  let(:customer2_items) { [i2_invoice_item1, i2_invoice_item2, customer2_transaction1] }

  let(:customer1_total) { customer1_items.sum(&:amount).exchange_to(org.default_currency).to_f.round(2) }
  let(:customer2_total) { customer2_items.sum(&:amount).exchange_to(org.default_currency).to_f.round(2) }

  let(:params) { {} }

  before do
    get path, headers: headers, params: params
  end

  it 'returns totals by customers statistic for current month' do
    expect(response).to be_successful

    statistic_json = json_body.statistic

    expect(statistic_json.data.map(&:to_h).sort_by { |el| el['name'] }).to eq([
      {
        'name'  => "#{customer1.name} #{Money.new(customer1_total * 100, 'RUB').format(symbol_after_without_space: true)}",
        'value' => customer1_total,
      },
      {
        'name'  => "#{customer2.name} #{Money.new(customer2_total * 100, 'RUB').format(symbol_after_without_space: true)}",
        'value' => customer2_total,
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

    let(:customer1_items) { [i1_invoice_item3, customer1_transaction2] }
    let(:customer2_items) { [i2_invoice_item3] }

    it 'returns totals by customers statistic for provided period' do
      expect(response).to be_successful

      statistic_json = json_body.statistic

      expect(statistic_json.data.map(&:to_h)).to eq([
        {
          'name'  => "#{customer1.name} #{Money.new(customer1_total * 100, 'RUB').format(symbol_after_without_space: true)}",
          'value' => customer1_total,
        },
        {
          'name'  => customer2.name,
          'value' => customer2_total,
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
    let!(:i1_invoice_item1)       {}
    let!(:i1_invoice_item2)       {}
    let!(:i1_invoice_item3)       {}
    let!(:i2_invoice_item1)       {}
    let!(:i2_invoice_item2)       {}
    let!(:i2_invoice_item3)       {}
    let!(:customer1_transaction1) {}
    let!(:customer1_transaction2) {}
    let!(:customer2_transaction1) {}

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
