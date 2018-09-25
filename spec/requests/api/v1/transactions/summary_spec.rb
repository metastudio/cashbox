# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/organizations/#/transactions/summary' do
  let(:path)    { summary_api_organization_transactions_path(organization) }
  let(:headers) { auth_header(user) }

  let(:organization) { create :organization, default_currency: 'RUB' }
  let(:user)         { create :user, organization: organization }

  let(:bank_account1) { create :bank_account, organization: organization, currency: 'RUB' }
  let(:bank_account2) { create :bank_account, organization: organization, currency: 'RUB' }

  let!(:income_transaction1)  { create :transaction, :income,  :with_customer, bank_account: bank_account1 }
  let!(:income_transaction2)  { create :transaction, :income,  :with_customer, bank_account: bank_account2 }
  let!(:income_transaction3)  { create :transaction, :income,  :with_customer, bank_account: bank_account2 }
  let!(:expense_transaction1) { create :transaction, :expense, :with_customer, bank_account: bank_account1 }
  let!(:expense_transaction2) { create :transaction, :expense, :with_customer, bank_account: bank_account2 }
  let!(:expense_transaction3) { create :transaction, :expense, :with_customer, bank_account: bank_account2 }

  before do
    get path, headers: headers
  end

  it 'returns transactions summary' do
    expect(response).to be_success

    summary_json = json_body.transactions_summary
    expect(summary_json.income.to_h).to eq [
      income_transaction1, income_transaction2, income_transaction3,
    ].sum(&:amount).as_json
    expect(summary_json.expense.to_h).to eq [
      expense_transaction1, expense_transaction2, expense_transaction3,
    ].sum(&:amount).as_json
    expect(summary_json.total.to_h).to eq [
      income_transaction1, income_transaction2, income_transaction3,
      expense_transaction1, expense_transaction2, expense_transaction3,
    ].sum(&:amount).as_json
  end

  context 'if filtered by bank account' do
    let(:path) { summary_api_organization_transactions_path(organization, q: { bank_account_id_eq: bank_account2.id }) }

    it 'returns summary for transactions only within this bank account' do
      expect(response).to be_success

      summary_json = json_body.transactions_summary
      expect(summary_json.income.to_h).to eq [
        income_transaction2, income_transaction3,
      ].sum(&:amount).as_json
      expect(summary_json.expense.to_h).to eq [
        expense_transaction2, expense_transaction3,
      ].sum(&:amount).as_json
      expect(summary_json.total.to_h).to eq [
        income_transaction2, income_transaction3,
        expense_transaction2, expense_transaction3,
      ].sum(&:amount).as_json
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
