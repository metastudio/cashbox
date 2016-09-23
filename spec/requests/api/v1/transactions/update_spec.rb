require 'rails_helper'

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
        'amount' => '95₽',
        'comment' => "Updated Test Comment\nComission: 5₽"
      )
      transaction.reload
      expect(json['transaction']['category']).to     include( 'id' => transaction.category.id)
      expect(json['transaction']['bank_account']).to include( 'id' => bank_account.id)
      expect(json['transaction']['customer']).to     include( 'id' => transaction.customer.id)
    end
  end

  context 'authenticated as user' do
    before { put path, params: params, headers: auth_header(user) }

    it 'returns updated transaction' do
      expect(response).to be_success

      expect(json['transaction']).to include(
        'id' => transaction.id,
        'amount' => '95₽',
        'comment' => "Updated Test Comment\nComission: 5₽"
      )
      transaction.reload
      expect(json['transaction']['category']).to     include( 'id' => transaction.category.id)
      expect(json['transaction']['bank_account']).to include( 'id' => bank_account.id)
      expect(json['transaction']['customer']).to     include( 'id' => transaction.customer.id)
    end

    context 'with wrong params' do
      let!(:wrong_organization) { create :organization }
      let!(:wrong_bank_account) { create :bank_account, organization: wrong_organization }
      let!(:wrong_category) { create :category, :income, organization: wrong_organization }
      let!(:wrong_customer) { create :customer, organization: wrong_organization }
      let(:params) {
        { transaction: {
            bank_account_id: wrong_bank_account.id,
            category_id: wrong_category.id,
            customer_id: wrong_customer.id
          }
        }
      }

      it 'returns error' do
        expect(response).to_not be_success
        expect(json['error']).to include "bank_account_id" => ["is not associated with current organization"]
      end
    end
  end

  context 'authenticated as wrong user' do
    let!(:wrong_user) { create :user }

    before { put path, params: params, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to_not be_success
      expect(json).to be_empty
    end
  end
end
