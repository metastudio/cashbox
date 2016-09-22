require 'spec_helper'

describe 'GET /api/organizations/#/transactions/#' do
  let(:path) { "/api/organizations/#{organization.id}/transactions/#{transaction.id}" }

  let(:bank_account) { create :bank_account, organization: organization }
  let(:amount) { Money.new(10000, bank_account.currency) }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, owner: owner, with_user: user }
  let!(:transaction) { create :transaction, :income, :with_customer, bank_account: bank_account }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as owner' do
    before { get path, headers: auth_header(owner) }

    it 'returns transaction' do
      expect(response).to be_success

      expect(json['transaction']).to include(
        'id' => transaction.id,
        'amount' => transaction.amount.to_s,
        'comment' => transaction.comment
      )

      expect(json['transaction']['category']).to     include( 'id' => transaction.category.id)
      expect(json['transaction']['bank_account']).to include( 'id' => bank_account.id)
      expect(json['transaction']['customer']).to     include( 'id' => transaction.customer.id)
    end
  end

  context 'authenticated as user' do
    before { get path, headers: auth_header(user) }

    it 'returns transaction' do
      expect(response).to be_success

      expect(json['transaction']).to include(
        'id' => transaction.id,
        'amount' => transaction.amount.to_s,
        'comment' => transaction.comment
      )

      expect(json['transaction']['category']).to     include( 'id' => transaction.category.id)
      expect(json['transaction']['bank_account']).to include( 'id' => bank_account.id)
      expect(json['transaction']['customer']).to     include( 'id' => transaction.customer.id)
    end
  end
end
