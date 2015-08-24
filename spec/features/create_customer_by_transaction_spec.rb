require 'spec_helper'

describe 'create transaction', js: true do
  include MoneyHelper

  let(:user)          { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:category)     { create :category, organization: organization }
  let!(:account)      { create :bank_account, residue: 99999999, organization: organization }

  let(:amount_str)    { '1,232.23' }
  let(:category_name) { category.name }
  let(:account_name)  { account.name }
  let(:comment)       { 'Test transaction' }

  def create_transaction
    visit root_path
    click_on 'Add...'
    within '#new_transaction' do
      fill_in 'transaction[amount]', with: amount_str
      select category_name, from: 'transaction[category_id]' if category_name.present?
      select account_name, from: 'transaction[bank_account_id]' if account_name.present?
      fill_in 'transaction[comment]', with: comment
      select2('new_customer', css: '#s2id_transaction_customer_name', search: true)
    end
    click_on 'Create'
    page.has_content?(/(Please review the problems below)|(#{amount_str})/) # wait after page rerender
  end

  subject{ create_transaction; page }

  before :each do
    sign_in user
  end

  context 'with valid data' do
    it "creates a new transaction" do
      expect{ subject }.to change{ Transaction.count }.by(1)
    end

    it 'create a new customer' do
      expect{ subject }.to change{ Customer.count }.by(1)
    end

    it 'show a new customer' do
      create_transaction
      expect(page).to have_content 'new_customer'
    end
  end
end
