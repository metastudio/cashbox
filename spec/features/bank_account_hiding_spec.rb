require 'rails_helper'

describe 'bank account hiding' do
  include MoneyHelper

  let!(:user)         { create :user, :with_organization }
  let!(:organization) { user.organizations.first }
  let!(:bank_account) { create :bank_account, organization: organization }
  let!(:transaction)  { create :transaction, bank_account: bank_account }

  before do
    sign_in user
  end

  subject { page }

  context 'when account is shown' do
    before do
      visit root_path
    end

    it 'shows ordinary transaction' do
      is_expected.to have_css("#transaction_#{transaction.id}",
        text: money_with_symbol(transaction.amount))
    end

    it 'shows transaction in total' do
      is_expected.to have_css('#sidebar', text: money_with_symbol(transaction.amount))
    end

    it 'shows account on sidebar' do
      is_expected.to have_css("#bank_account_#{bank_account.id}",
        text: money_with_symbol(transaction.amount))
    end
  end

  context 'when hide account' do
    before do
      visit bank_accounts_path
      within "##{dom_id(bank_account)}" do
        click_on 'Hide'
      end
      visit root_path
    end

    it 'shows hidden transaction' do
      is_expected.to have_css("#transaction_#{transaction.id}",
        text: money_with_symbol(transaction.amount))
    end

    it 'doesnt show transaction in total' do
      is_expected.to have_no_css('#sidebar', text: money_with_symbol(transaction.amount))
    end

    it 'doesnt show account on sidebar' do
      is_expected.to have_no_css("#bank_account_#{bank_account.id}",
        text: money_with_symbol(transaction.amount))
    end
  end
end
