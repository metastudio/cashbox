require 'rails_helper'

describe 'POST /api/organizations/#/bank_accounts' do
  let(:path) { "/api/organizations/#{organization.id}/bank_accounts" }
  let(:amount) { Money.new(10000, bank_account.currency) }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, owner: owner, with_user: user }
  let(:params) {
    {
      bank_account: {
        name: 'Test Bank Account',
        balance: 0,
        currency: 'RUB'
      }
    }
  }

  context 'unauthenticated' do
    it { post(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as owner' do
    before { post path, params: params, headers: auth_header(owner) }

    it 'returns created bank account' do
      expect(response).to be_success

      expect(json).to include(
        'id' => BankAccount.last.id,
        'name' => 'Test Bank Account',
        'balance' => money_with_symbol(BankAccount.last.balance),
        'currency' => 'RUB'
      )
      expect(organization.bank_accounts.last.id).to eq BankAccount.last.id
    end

    context 'with wrong params' do
      let(:params) {
        { bank_account: {
            name: '',
            currency: nil
          }
        }
      }

      it 'returns error' do
        expect(response).to_not be_success

        expect(json).to include "name" => ["can't be blank"]
        expect(json).to include "currency" => ["can't be blank", " is not a valid currency"]
      end
    end
  end

  context 'authenticated as user' do
    before { post path, params: params, headers: auth_header(user) }

    it 'returns created bank account' do
      expect(response).to be_success

      expect(json).to include(
        'id' => BankAccount.last.id,
        'name' => 'Test Bank Account',
        'balance' => money_with_symbol(BankAccount.last.balance),
        'currency' => 'RUB'
      )
      expect(organization.bank_accounts.last.id).to eq BankAccount.last.id
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
