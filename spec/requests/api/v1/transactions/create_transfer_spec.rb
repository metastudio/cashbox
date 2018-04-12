require 'rails_helper'

describe 'POST /api/organizations/#/transactions/transfer' do
  let(:path) { "/api/organizations/#{organization.id}/transactions/transfer" }

  let(:from_bank_account) { create :bank_account, organization: organization }
  let(:to_bank_account) { create :bank_account, organization: organization }
  let(:amount) { Money.new(10000, from_bank_account.currency) }
  let(:comission) { Money.new(1000, to_bank_account.currency) }
  let(:exchange_rate) { 2.5 }
  let(:comment) { 'Test comment' }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, owner: owner, with_user: user }
  let(:params) {
    {
      transfer: {
        amount: amount,
        comission: comission,
        bank_account_id: from_bank_account.id,
        reference_id: to_bank_account.id,
        exchange_rate: exchange_rate,
        comment: comment,
        date: Time.current
      }
    }
  }

  context 'unauthenticated' do
    it { post(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as owner' do
    before { post path, params: params, headers: auth_header(owner) }

    it 'returns ok and creates transfer' do
      expect(response).to be_success

      expect(json).to be_empty

      expect(organization.transactions.count).to eq 2
      expect(organization.transactions.first.bank_account).to eq to_bank_account
      expect(organization.transactions.last.bank_account).to eq from_bank_account
    end

    context 'with wrong params' do
      let(:params) {
        { transfer: {
            amount: '0',
            bank_account_id: nil,
            reference_id: nil
          }
        }
      }

      it 'returns error' do
        expect(response).to_not be_success

        expect(json).to include "amount" => ["must be other than 0"]
        expect(json).to include "bank_account_id" => ["can't be blank"]
        expect(json).to include "reference_id" => ["can't be blank", "Can't transfer to same account"]
      end
    end
  end

  context 'authenticated as user' do
    before { post path, params: params, headers: auth_header(user) }

    it 'returns ok and creates transfer' do
      expect(response).to be_success

      expect(json).to be_empty

      expect(organization.transactions.count).to eq 2
      expect(organization.transactions.first.bank_account).to eq to_bank_account
      expect(organization.transactions.last.bank_account).to eq from_bank_account
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
