# frozen_string_literal: true

require 'rails_helper'

describe 'POST /api/organizations/#/transactions' do
  let(:path) { "/api/organizations/#{organization.id}/transactions" }

  let(:bank_account) { create :bank_account, organization: organization }
  let(:amount) { '21100.11' }
  let(:category) { create :category, :income, organization: organization }
  let(:customer) { create :customer, organization: organization }

  let!(:user) { create :user }
  let!(:organization) { create :organization, with_user: user }
  let(:params) {
    {
      transaction: {
        amount:          amount,
        category_id:     category.id,
        bank_account_id: bank_account.id,
        comment:         'Test Comment',
        comission:       5,
        customer_id:     customer.id,
        date:            Time.current
      }
    }
  }

  context 'unauthenticated' do
    it { post(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as user' do
    before { post path, params: params, headers: auth_header(user) }

    it 'returns created transaction' do
      expect(response).to be_success

      expect(json).to include(
        'id'        => Transaction.last.id,
        'amount'    => Transaction.last.amount.as_json,
        'comment'   => "Test Comment\nComission: 5₽",
        'comission' => '5'
      )

      expect(json['category']).to     include('id' => category.id)
      expect(json['bank_account']).to include('id' => bank_account.id)
      expect(json['customer']).to     include('id' => customer.id)

      expect(organization.transactions.last.id).to eq Transaction.last.id
      expect(organization.transactions.last.amount).to eq Money.from_amount(21095.11, bank_account.currency)
      expect(organization.transactions.last.created_by).to eq user
    end

    context 'with wrong params' do
      let(:params) {
        {
          transaction: {
            amount:          '0',
            bank_account_id: nil,
            category_id:     nil
          }
        }
      }

      it 'returns error' do
        expect(response).to_not be_success

        expect(json).to include "amount" => ["must be other than 0"]
        expect(json).to include "category" => ["can't be blank"]
        expect(json).to include "bank_account" => ["can't be blank"]
      end
    end

    context 'with wrong params' do
      let(:params) {
        {
          transaction: {
            amount:          '23.23',
            bank_account_id: nil,
            category_id:     nil
          }
        }
      }

      it 'returns error' do
        expect(response).to_not be_success

        expect(json).to_not include "amount"
        expect(json).to include "category" => ["can't be blank"]
        expect(json).to include "bank_account" => ["can't be blank"]
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
