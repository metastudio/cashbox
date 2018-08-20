# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/organizations/#/transactions/#' do
  let(:path) { api_organization_transaction_path(organization, transaction) }
  let(:headers) { auth_header(user) }

  let(:organization) { create :organization }
  let(:user) { create :user, organization: organization }

  let(:amount) { Money.from_amount(100, bank_account.currency) }

  let(:category)     { create :category, :income, organization: organization }
  let(:bank_account) { create :bank_account, organization: organization }
  let(:customer)     { create :customer, organization: organization }
  let(:invoice)      { create :invoice, organization: organization, customer: customer, amount: amount }

  let!(:transaction) do
    create(
      :transaction, :income,
      category:     category,
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

    invoice.reload

    expect(json_body.id).to              eq transaction.id
    expect(json_body.amount.to_h).to     eq transaction.amount.as_json
    expect(json_body.comment).to         eq transaction.comment
    expect(json_body.is_viewed).to       eq true
    expect(json_body.category_id).to     eq category.id
    expect(json_body.bank_account_id).to eq bank_account.id
    expect(json_body.customer_id).to     eq customer.id
    expect(json_body.invoice_id).to      eq invoice.id

    expect(json_body.category).to     be_short_category_json(category)
    expect(json_body.bank_account).to be_short_bank_account_json(bank_account)
    expect(json_body.customer).to     be_short_customer_json(customer)
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
