# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/organizations/#/transactions' do
  let(:path)    { api_organization_transactions_path(organization) }
  let(:headers) { auth_header(user) }

  let(:organization) { create :organization }
  let(:user)         { create :user }
  let!(:member)      { create :member, user: user, organization: organization, last_visited_at: Time.current }

  let!(:bank_account)    { create :bank_account, organization: organization }
  let!(:to_bank_account) { create :bank_account, organization: organization }

  let!(:seen_transaction) { create :transaction, :income, :with_customer, bank_account: bank_account, created_at: 1.day.ago }
  let!(:transaction)      { create :transaction, :expense, :with_customer, bank_account: bank_account }
  let!(:transfer)         { create :transfer, bank_account_id: bank_account.id, reference_id: to_bank_account.id }

  let(:transfer_in)  { transfer.inc_transaction }
  let(:transfer_out) { transfer.out_transaction }

  before do
    get path, headers: headers
  end

  it 'returns transactions' do
    expect(response).to be_successful

    expect(json_body.transactions.size).to eq 3
    expect(json_body.transactions.map(&:id)).to eq [transfer_in.id, transaction.id, seen_transaction.id]

    transfer_in_json = json_body.transactions.find{ |j| j.id == transfer_in.id }
    expect(transfer_in_json.id).to           eq transfer_in.id
    expect(transfer_in_json.amount.to_h).to  eq transfer_in.amount.as_json
    expect(transfer_in_json.comment).to      eq transfer_in.comment
    expect(transfer_in_json.is_viewed).to    eq false
    expect(transfer_in_json.category).to     be_short_category_json(transfer_in.category)
    expect(transfer_in_json.bank_account).to be_short_bank_account_json(transfer_in.bank_account)

    transfer_out_json = transfer_in_json.transfer_out
    expect(transfer_out_json.id).to           eq transfer_out.id
    expect(transfer_out_json.amount.to_h).to  eq transfer_out.amount.as_json
    expect(transfer_out_json.comment).to      eq transfer_out.comment
    expect(transfer_out_json.category).to     be_short_category_json(transfer_out.category)
    expect(transfer_out_json.bank_account).to be_short_bank_account_json(transfer_out.bank_account)

    transaction_json = json_body.transactions.find{ |j| j.id == transaction.id }
    expect(transaction_json.id).to           eq transaction.id
    expect(transaction_json.amount.to_h).to  eq transaction.amount.as_json
    expect(transaction_json.comment).to      eq transaction.comment
    expect(transaction_json.is_viewed).to    eq false
    expect(transaction_json.category).to     be_short_category_json(transaction.category)
    expect(transaction_json.bank_account).to be_short_bank_account_json(transaction.bank_account)
    expect(transaction_json.customer).to     be_short_customer_json(transaction.customer)

    transaction_json = json_body.transactions.find{ |j| j.id == seen_transaction.id }
    expect(transaction_json.id).to           eq seen_transaction.id
    expect(transaction_json.amount.to_h).to  eq seen_transaction.amount.as_json
    expect(transaction_json.comment).to      eq seen_transaction.comment
    expect(transaction_json.is_viewed).to    eq true
    expect(transaction_json.category).to     be_short_category_json(seen_transaction.category)
    expect(transaction_json.bank_account).to be_short_bank_account_json(seen_transaction.bank_account)
    expect(transaction_json.customer).to     be_short_customer_json(seen_transaction.customer)
  end

  context 'if filtered by bank account' do
    let(:path) { api_organization_transactions_path(organization, q: { bank_account_id_eq: bank_account.id }) }

    it 'includes out transaction for this bank account' do
      expect(response).to be_successful

      expect(json_body.transactions.size).to eq 3
      expect(json_body.transactions.map(&:id)).to eq [transfer_in.id, transaction.id, seen_transaction.id]

      transfer_in_json = json_body.transactions.find{ |j| j.id == transfer_in.id }
      expect(transfer_in_json.id).to           eq transfer_in.id
      expect(transfer_in_json.amount.to_h).to  eq transfer_in.amount.as_json
      expect(transfer_in_json.comment).to      eq transfer_in.comment
      expect(transfer_in_json.is_viewed).to    eq false
      expect(transfer_in_json.category).to     be_short_category_json(transfer_in.category)
      expect(transfer_in_json.bank_account).to be_short_bank_account_json(transfer_in.bank_account)

      transfer_out_json = transfer_in_json.transfer_out
      expect(transfer_out_json.id).to           eq transfer_out.id
      expect(transfer_out_json.amount.to_h).to  eq transfer_out.amount.as_json
      expect(transfer_out_json.comment).to      eq transfer_out.comment
      expect(transfer_out_json.category).to     be_short_category_json(transfer_out.category)
      expect(transfer_out_json.bank_account).to be_short_bank_account_json(transfer_out.bank_account)
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
