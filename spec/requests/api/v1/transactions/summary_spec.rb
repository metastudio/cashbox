# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/organizations/#/transactions/summary' do
  let(:path)    { summary_api_organization_transactions_path(organization) }
  let(:headers) { auth_header(user) }

  let(:organization) { create :organization, default_currency: 'RUB' }
  let(:user)         { create :user, organization: organization }

  let(:rub_bank_account) { create :bank_account, organization: organization, currency: 'RUB' }
  let(:usd_bank_account) { create :bank_account, organization: organization, currency: 'USD' }
  let(:eur_bank_account) { create :bank_account, organization: organization, currency: 'EUR' }

  let!(:rub_income_transaction1)  { create :transaction, :income,  :with_customer, bank_account: rub_bank_account }
  let!(:rub_income_transaction2)  { create :transaction, :income,  :with_customer, bank_account: rub_bank_account }
  let!(:usd_income_transaction1)  { create :transaction, :income,  :with_customer, bank_account: usd_bank_account }
  let!(:usd_income_transaction2)  { create :transaction, :income,  :with_customer, bank_account: usd_bank_account }
  let!(:eur_income_transaction1)  { create :transaction, :income,  :with_customer, bank_account: eur_bank_account }
  let!(:eur_income_transaction2)  { create :transaction, :income,  :with_customer, bank_account: eur_bank_account }
  let!(:rub_expense_transaction1) { create :transaction, :expense, :with_customer, bank_account: rub_bank_account }
  let!(:rub_expense_transaction2) { create :transaction, :expense, :with_customer, bank_account: rub_bank_account }
  let!(:usd_expense_transaction1) { create :transaction, :expense, :with_customer, bank_account: usd_bank_account }
  let!(:usd_expense_transaction2) { create :transaction, :expense, :with_customer, bank_account: usd_bank_account }
  let!(:eur_expense_transaction1) { create :transaction, :expense, :with_customer, bank_account: eur_bank_account }
  let!(:eur_expense_transaction2) { create :transaction, :expense, :with_customer, bank_account: eur_bank_account }

  let(:rub_income)  { [rub_income_transaction1, rub_income_transaction2].sum(&:amount) }
  let(:usd_income)  { [usd_income_transaction1, usd_income_transaction2].sum(&:amount) }
  let(:eur_income)  { [eur_income_transaction1, eur_income_transaction2].sum(&:amount) }
  let(:rub_expense) { [rub_expense_transaction1, rub_expense_transaction2].sum(&:amount) }
  let(:usd_expense) { [usd_expense_transaction1, usd_expense_transaction2].sum(&:amount) }
  let(:eur_expense) { [eur_expense_transaction1, eur_expense_transaction2].sum(&:amount) }
  let(:rub_diff)    { [rub_income_transaction1, rub_income_transaction2, rub_expense_transaction1, rub_expense_transaction2].sum(&:amount) }
  let(:usd_diff)    { [usd_income_transaction1, usd_income_transaction2, usd_expense_transaction1, usd_expense_transaction2].sum(&:amount) }
  let(:eur_diff)    { [eur_income_transaction1, eur_income_transaction2, eur_expense_transaction1, eur_expense_transaction2].sum(&:amount) }

  let(:total_income) do
    [
      [rub_income_transaction1, rub_income_transaction2],
      [usd_income_transaction1, usd_income_transaction2],
      [eur_income_transaction1, eur_income_transaction2],
    ].map{ |flow| flow.sum(&:amount) }.flatten.map{ |f| f.exchange_to(organization.default_currency) }.sum
  end
  let(:total_expense) do
    [
      [rub_expense_transaction1, rub_expense_transaction2],
      [usd_expense_transaction1, usd_expense_transaction2],
      [eur_expense_transaction1, eur_expense_transaction2],
    ].map{ |flow| flow.sum(&:amount) }.flatten.map{ |f| f.exchange_to(organization.default_currency) }.sum
  end
  let(:total_diff) do
    [
      [rub_income_transaction1, rub_income_transaction2, rub_expense_transaction1, rub_expense_transaction2],
      [usd_income_transaction1, usd_income_transaction2, usd_expense_transaction1, usd_expense_transaction2],
      [eur_income_transaction1, eur_income_transaction2, eur_expense_transaction1, eur_expense_transaction2],
    ].map{ |flow| flow.sum(&:amount) }.flatten.map{ |f| f.exchange_to(organization.default_currency) }.sum
  end

  before do
    get path, headers: headers
  end

  it 'returns transactions summary' do
    expect(response).to be_successful

    rub_json = json_body.transactions_summary.RUB
    expect(rub_json.income.to_h).to     eq rub_income.as_json
    expect(rub_json.expense.to_h).to    eq rub_expense.as_json
    expect(rub_json.difference.to_h).to eq rub_diff.as_json

    usd_json = json_body.transactions_summary.USD
    expect(usd_json.income.to_h).to     eq usd_income.as_json
    expect(usd_json.expense.to_h).to    eq usd_expense.as_json
    expect(usd_json.difference.to_h).to eq usd_diff.as_json

    eur_json = json_body.transactions_summary.EUR
    expect(eur_json.income.to_h).to     eq eur_income.as_json
    expect(eur_json.expense.to_h).to    eq eur_expense.as_json
    expect(eur_json.difference.to_h).to eq eur_diff.as_json

    total_json = json_body.transactions_summary.total
    expect(total_json.income.to_h).to     eq total_income.as_json
    expect(total_json.expense.to_h).to    eq total_expense.as_json
    expect(total_json.difference.to_h).to eq total_diff.as_json
  end

  context 'if filtered by bank account' do
    let(:path) { summary_api_organization_transactions_path(organization, q: { bank_account_id_eq: usd_bank_account.id }) }

    let(:usd_income)  { [usd_income_transaction1, usd_income_transaction2].sum(&:amount) }
    let(:usd_expense) { [usd_expense_transaction1, usd_expense_transaction2].sum(&:amount) }
    let(:usd_diff)    { [usd_income_transaction1, usd_income_transaction2, usd_expense_transaction1, usd_expense_transaction2].sum(&:amount) }

    let(:total_income) do
      [
        usd_income_transaction1, usd_income_transaction2,
      ].sum(&:amount).exchange_to(organization.default_currency)
    end
    let(:total_expense) do
      [
        usd_expense_transaction1, usd_expense_transaction2,
      ].sum(&:amount).exchange_to(organization.default_currency)
    end
    let(:total_diff) do
      [
        usd_income_transaction1, usd_income_transaction2,
        usd_expense_transaction1, usd_expense_transaction2,
      ].sum(&:amount).exchange_to(organization.default_currency)
    end

    it 'returns summary for transactions only within this bank account' do
      expect(response).to be_successful

      expect(json_body.transactions_summary).not_to respond_to 'RUB'
      expect(json_body.transactions_summary).not_to respond_to 'EUR'

      usd_json = json_body.transactions_summary.USD
      expect(usd_json.income.to_h).to     eq usd_income.as_json
      expect(usd_json.expense.to_h).to    eq usd_expense.as_json
      expect(usd_json.difference.to_h).to eq usd_diff.as_json

      total_json = json_body.transactions_summary.total
      expect(total_json.income.to_h).to     eq total_income.as_json
      expect(total_json.expense.to_h).to    eq total_expense.as_json
      expect(total_json.difference.to_h).to eq total_diff.as_json
    end
  end

  context 'when not authenticated' do
    let(:headers) { {} }

    it 'returns anauthorize error' do
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
