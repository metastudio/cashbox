require 'rails_helper'

describe 'GET /api/organizations/#/transactions/#' do
  let(:path) { "/api/organizations/#{organization.id}/transactions/#{transaction.id}" }

  let(:bank_account) { create :bank_account, organization: organization }
  let(:amount) { Money.from_amount(100, bank_account.currency) }

  let!(:user) { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:transaction) { create :transaction, :income, :with_customer, bank_account: bank_account }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as user' do
    before { get path, headers: auth_header(user) }

    it 'returns transaction' do
      expect(response).to be_success

      expect(json).to include(
        'id' => transaction.id,
        'amount' => money_with_symbol(transaction.amount),
        'comment' => transaction.comment
      )

      expect(json['category']).to     include( 'id' => transaction.category.id)
      expect(json['bank_account']).to include( 'id' => transaction.bank_account.id)
      expect(json['customer']).to     include( 'id' => transaction.customer.id)
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
