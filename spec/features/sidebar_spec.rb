require 'spec_helper'

describe 'sidebar' do
  include MoneyHelper
  let(:user)    { create :user }
  let(:org)     { create :organization }
  let!(:member) { create :member, organization: org, user: user, role: 'owner' }
  let(:amount)  { 5000 }
  let!(:account){ create :bank_account, organization: org, balance: amount }

  before do
    sign_in user
    visit root_path
  end

  subject { page }

  context 'accounts' do
    it_behaves_like 'colorizable amount', 'table'
  end

  context 'total' do
    it_behaves_like 'colorizable amount', '#total_balance'

    it 'display exhanged amount' do
      within '#total_balance' do
        expect(page).to have_content(
          money_with_symbol account.balance.exchange_to(org.default_currency))
      end
    end

    it 'display exchange rate' do
      within '#total_balance' do
        expect(page).to have_xpath("//a[contains(concat(' ', @class, ' '), ' exchange-helper ') and contains(@title, '#{Money.default_bank.get_rate(account.currency, org.default_currency).round(4)}')]")
      end
    end

    it 'display total balance in default currency' do
      within '#total_balance' do
        expect(page).to have_content money_with_symbol(account.balance.exchange_to(org.default_currency))
      end
    end
  end
end
