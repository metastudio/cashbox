# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/organizations/#/transactions' do
  let(:path) { "/api/organizations/#{organization.id}/transactions" }
  let!(:user) { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:bank_account) { create :bank_account, organization: organization }
  let!(:to_bank_account) { create :bank_account, organization: organization }
  let!(:transaction1) { create :transaction, :income, :with_customer, bank_account: bank_account }
  let!(:transaction2) { create :transaction, :expense, :with_customer, bank_account: bank_account }
  let!(:transfer)     { create :transfer, bank_account_id: bank_account.id, reference_id: to_bank_account.id }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as user' do
    before { get path, headers: auth_header(user) }

    it 'returns transactions' do
      expect(response).to be_success

      transfer_in = Transaction.where.not(transfer_out_id: nil).first
      transfer_out = Transaction.find(transfer_in.transfer_out_id)

      expect(json[0]).to include(
        'id'      => transfer_in.id,
        'amount'  => transfer_in.amount.as_json,
        'comment' => transfer_in.comment,
      )
      expect(json[0]['category']).to     include('id' => transfer_in.category.id)
      expect(json[0]['bank_account']).to include('id' => transfer_in.bank_account.id)
      expect(json[0]['transfer_out']).to include(
        'id'      => transfer_out.id,
        'amount'  => transfer_out.amount.as_json,
        'comment' => transfer_out.comment,
      )
      expect(json[0]['transfer_out']['category']).to     include('id' => transfer_out.category.id)
      expect(json[0]['transfer_out']['bank_account']).to include('id' => transfer_out.bank_account.id)

      expect(json[1]).to include(
        'id'      => transaction2.id,
        'amount'  => transaction2.amount.as_json,
        'comment' => transaction2.comment
      )
      expect(json[1]['category']).to     include('id' => transaction2.category.id)
      expect(json[1]['bank_account']).to include('id' => transaction2.bank_account.id)
      expect(json[1]['customer']).to     include('id' => transaction2.customer.id)

      expect(json[2]).to include(
        'id'      => transaction1.id,
        'amount'  => transaction1.amount.as_json,
        'comment' => transaction1.comment
      )
      expect(json[2]['category']).to     include('id' => transaction1.category.id)
      expect(json[2]['bank_account']).to include('id' => transaction1.bank_account.id)
      expect(json[2]['customer']).to     include('id' => transaction1.customer.id)
    end
  end

  context 'authenticated as wrong user' do
    let!(:wrong_user) { create :user }

    before { get path, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to_not be_success
      expect(json).to be_empty
    end
  end
end
