# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/organizations/#/transactions' do
  let(:path) { "/api/organizations/#{organization.id}/transactions" }

  let(:bank_account) { create :bank_account, organization: organization }

  let!(:user) { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:transaction1) { create :transaction, :income, :with_customer, bank_account: bank_account }
  let!(:transaction2) { create :transaction, :expense, :with_customer, bank_account: bank_account }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as user' do
    before { get path, headers: auth_header(user) }

    it 'returns transactions' do
      expect(response).to be_success

      expect(json[0]).to include(
        'id'      => transaction2.id,
        'amount'  => transaction2.amount.as_json,
        'comment' => transaction2.comment
      )
      expect(json[0]['category']).to     include('id' => transaction2.category.id)
      expect(json[0]['bank_account']).to include('id' => transaction2.bank_account.id)
      expect(json[0]['customer']).to     include('id' => transaction2.customer.id)

      expect(json[1]).to include(
        'id'      => transaction1.id,
        'amount'  => transaction1.amount.as_json,
        'comment' => transaction1.comment
      )
      expect(json[1]['category']).to     include('id' => transaction1.category.id)
      expect(json[1]['bank_account']).to include('id' => transaction1.bank_account.id)
      expect(json[1]['customer']).to     include('id' => transaction1.customer.id)
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
