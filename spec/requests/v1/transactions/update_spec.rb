require 'spec_helper'

describe 'PUT /api/organizations/#/transactions/#' do
  let(:path) { "/api/organizations/#{organization.id}/transactions/#{transaction.id}" }

  let(:bank_account) { create :bank_account, organization: organization }
  let(:amount) { Money.new(10000, bank_account.currency) }
  let(:category) { create :category, :income, organization: organization }
  let(:customer) { create :customer, organization: organization }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, owner: owner, with_user: user }
  let!(:transaction) { create :transaction, :income, :with_customer, organization: organization }
  let(:params) {
    {
      transaction: {
        amount: amount,
        category_id: category.id,
        bank_account_id: bank_account.id,
        comment: 'Updated Test Comment',
        comission: 5,
        customer_id: customer.id,
        date: Time.current
      }
    }
  }

  context 'unauthenticated' do
    it { put(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as owner' do
    before { put path, params: params, headers: auth_header(owner) }

    it 'returns updated transaction' do
      expect(response).to be_success

      expect(json['transaction']).to include(
        'id' => transaction.id,
        'amount' => '95.00',
        'comment' => "Updated Test Comment\nComission: 5₽"
      )
      transaction.reload
      expect(json['transaction']['category']).to     include( 'id' => transaction.category.id)
      expect(json['transaction']['bank_account']).to include( 'id' => bank_account.id)
      expect(json['transaction']['customer']).to     include( 'id' => transaction.customer.id)
    end
  end

  context 'authenticated as user' do
    before { put path, params: params, headers: auth_header(owner) }

    it 'returns updated transaction' do
      expect(response).to be_success

      expect(json['transaction']).to include(
        'id' => transaction.id,
        'amount' => '95.00',
        'comment' => "Updated Test Comment\nComission: 5₽"
      )
      transaction.reload
      expect(json['transaction']['category']).to     include( 'id' => transaction.category.id)
      expect(json['transaction']['bank_account']).to include( 'id' => bank_account.id)
      expect(json['transaction']['customer']).to     include( 'id' => transaction.customer.id)
    end
  end
end
