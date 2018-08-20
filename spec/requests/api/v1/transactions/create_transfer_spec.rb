# frozen_string_literal: true

require 'rails_helper'

describe 'POST /api/organizations/#/transactions/transfer' do
  let(:path) { "/api/organizations/#{organization.id}/transactions/transfer" }

  let(:from_bank_account) { create :bank_account, organization: organization, currency: 'USD' }
  let(:to_bank_account) { create :bank_account, organization: organization, currency: 'RUB' }
  let(:amount) { Money.from_amount(100, from_bank_account.currency) }
  let(:comission) { Money.from_amount(10, to_bank_account.currency) }
  let(:exchange_rate) { 62.5 }
  let(:comment) { 'Test comment' }

  let!(:user) { create :user }
  let!(:organization) { create :organization, with_user: user }
  let(:params) do
    {
      transfer: {
        amount:          amount,
        comission:       comission,
        bank_account_id: from_bank_account.id,
        reference_id:    to_bank_account.id,
        exchange_rate:   exchange_rate,
        comment:         comment,
        date:            Date.current,
      },
    }
  end

  context 'unauthenticated' do
    it { post(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as user' do
    before { post path, params: params, headers: auth_header(user) }

    it 'returns ok and creates transfer' do
      expect(response).to be_success

      expect(organization.transactions.count).to eq 2

      to_transaction = organization.transactions.first
      expect(to_transaction.bank_account).to eq to_bank_account
      expect(to_transaction.amount_cents).to eq 625_000
      from_transaction = organization.transactions.last
      expect(from_transaction.bank_account).to eq from_bank_account
      expect(from_transaction.amount_cents).to eq(-11_000)

      expect(json).to include(
        'id'     => to_transaction.id,
        'amount' => to_transaction.amount.as_json,
      )
      expect(json['bank_account']).to include('id' => to_bank_account.id)
    end

    context 'with wrong params' do
      let(:params) do
        {
          transfer: {
            amount:          '0',
            bank_account_id: nil,
            reference_id:    nil,
          },
        }
      end

      it 'returns error' do
        expect(response).to_not be_success

        expect(json).to include 'amount' => ['must be other than 0']
        expect(json).to include 'bank_account_id' => ['can\'t be blank']
        expect(json).to include 'reference_id' => ['can\'t be blank', 'Can\'t transfer to same account']
      end
    end
  end

  context 'authenticated as wrong user' do
    let!(:wrong_user) { create :user }
    before { post path, params: params, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to_not be_success
      expect(json).to be_empty
    end
  end
end
