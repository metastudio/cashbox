# frozen_string_literal: true

require 'rails_helper'

describe 'POST /api/organizations/#/transactions' do
  include MoneyRails::ActionViewExtension

  let(:path) { api_organization_transactions_path(organization) }
  let(:headers) { auth_header(user) }

  let(:organization) { create :organization }
  let(:user)         { create :user, organization: organization }

  let(:bank_account) { create :bank_account, organization: organization }
  let(:category)     { create :category, :income, organization: organization }
  let(:customer)     { create :customer, organization: organization }
  let(:amount)       { Money.from_amount(21_095.11, bank_account.currency) }
  let(:comission)    { Money.from_amount(5.05, bank_account.currency) }
  let(:comment)      { generate :transaction_comment }

  let(:params) do
    {
      transaction: {
        category_id:     category.id,
        bank_account_id: bank_account.id,
        customer_id:     customer.id,
        date:            Date.current,
        amount:          amount.to_s,
        comment:         comment,
        comission:       comission.to_s,
      },
    }
  end

  before do
    post path, params: params, headers: headers
  end

  it 'returns created transaction' do
    expect(response).to be_success

    transaction = Transaction.unscoped.last
    expect(transaction.bank_account_id).to eq bank_account.id
    expect(transaction.category_id).to     eq category.id
    expect(transaction.customer_id).to     eq customer.id
    expect(transaction.amount).to          eq amount - comission
    expect(transaction.created_by_id).to   eq user.id
    expect(transaction.invoice_id).to      eq nil
    expect(transaction.comment).to         eq "#{comment}\nComission: #{humanized_money_with_symbol(comission, symbol_after_without_space: true)}"

    expect(json_body.id).to              eq transaction.id
    expect(json_body.amount.to_h).to     eq transaction.amount.as_json
    expect(json_body.comment).to         eq transaction.comment
    expect(json_body.is_viewed).to       eq true
    expect(json_body.category_id).to     eq category.id
    expect(json_body.bank_account_id).to eq bank_account.id
    expect(json_body.customer_id).to     eq customer.id
    expect(json_body.invoice_id).to      eq nil

    expect(json_body.category).to     be_short_category_json(category)
    expect(json_body.bank_account).to be_short_bank_account_json(bank_account)
    expect(json_body.customer).to     be_short_customer_json(customer)
  end

  context 'if invoice_id is provided' do
    let(:invoice) { create :invoice, organization: organization, customer: customer, amount: amount }

    let(:params) do
      {
        transaction: {
          category_id:     category.id,
          bank_account_id: bank_account.id,
          customer_id:     customer.id,
          invoice_id:      invoice.id,
          date:            Date.current,
          amount:          amount.to_s,
          comment:         comment,
          comission:       comission.to_s,
        },
      }
    end

    it 'marks invoice as completed' do
      expect(response).to be_success

      invoice.reload
      expect(invoice).to be_completed

      transaction = Transaction.unscoped.last
      expect(transaction.invoice_id).to eq invoice.id

      expect(json_body.invoice_id).to eq transaction.invoice_id
    end
  end

  context 'with wrong params' do
    let(:params) do
      {
        transaction: {
          amount:          '0',
          bank_account_id: nil,
          category_id:     nil,
        },
      }
    end

    it 'returns error' do
      expect(response.code).to eq '422'

      expect(json_body.amount).to           eq ['must be other than 0']
      expect(json_body.category).to         eq ['can\'t be blank']
      expect(json_body.category_id).to      eq ['can\'t be blank']
      expect(json_body.bank_account).to     eq ['can\'t be blank']
      expect(json_body.bank_account_id).to  eq ['can\'t be blank']
    end
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
