# frozen_string_literal: true

require 'rails_helper'

describe 'create transaction' do
  include MoneyHelper

  subject{ page }

  let(:org)  { create :organization }
  let(:user) { create :user, organization: org }

  let!(:category) { create :category, organization: org }
  let!(:account)  { create :bank_account, residue: 99_999_999, organization: org }

  let(:amount)        { Money.from_amount(24_324.34, account.currency) }
  let(:customer_name) { generate :customer_name }

  before :each do
    sign_in user

    visit root_path
    click_on 'Add...'
  end

  it 'creates a new transaction and customer', js: true do
    within '#new_transaction' do
      fill_in 'Amount', with: amount
      select category.name, from: 'Category'
      select account.name, from: 'Bank account'
      select2(customer_name, css: '#s2id_transaction_customer_name', search: true)
    end
    click_on 'Create'
    page.has_content?(/(Please review the problems below)|(#{money_with_symbol(amount)})/) # wait after page rerender

    customer = Customer.unscoped.last
    expect(customer.name).to         eq customer_name
    expect(customer.organization).to eq org

    transaction = Transaction.unscoped.last
    expect(transaction.amount).to eq amount
    expect(transaction.customer).to eq customer
    expect(transaction.category).to eq category
  end
end
