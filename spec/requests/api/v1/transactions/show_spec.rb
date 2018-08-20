# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/organizations/#/transactions/#' do
  let(:path) { api_organization_transaction_path(organization, transaction) }
  let(:headers) { auth_header(user) }

  let(:organization) { create :organization }
  let(:user) { create :user, organization: organization }

  let(:amount) { Money.from_amount(100, bank_account.currency) }

  let(:bank_account) { create :bank_account, organization: organization }
  let(:customer)     { create :customer,     organization: organization }
  let(:invoice)      { create :invoice,      organization: organization, customer: customer, amount: amount }

  let!(:transaction) do
    create(
      :transaction, :income,
      bank_account: bank_account,
      customer:     customer,
      invoice:      invoice,
      amount:       amount,
    )
  end

  before do
    get path, headers: headers
  end

  it 'returns transaction' do
    expect(response).to be_success

    expect(json).to include(
      'id'              => transaction.id,
      'amount'          => transaction.amount.as_json,
      'comment'         => transaction.comment,
      'is_viewed'       => true,
      'category_id'     => transaction.category.id,
      'bank_account_id' => bank_account.id,
      'customer_id'     => customer.id,
      'invoice_id'      => invoice.id,
    )

    expect(json['category']).to     include('id' => transaction.category.id)
    expect(json['bank_account']).to include('id' => bank_account.id)
    expect(json['customer']).to     include('id' => customer.id)
    expect(json['invoice']).to      include('id' => invoice.id)
  end

  context 'unauthenticated' do
    let(:headers) { {} }

    it 'returns Unauthorized error' do
      expect(response).to(be_unauthorized)
    end
  end

  context 'authenticated as user not associated with orgnaization' do
    let(:user) { create :user }

    it 'returns Not Found error' do
      expect(response).to be_not_found
      expect(json).to be_empty
    end
  end
end
