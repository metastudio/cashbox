require 'spec_helper'

describe 'sidebar' do
  include MoneyHelper

  let(:user)   { create :user }
  let(:member) { create :member, user: user }
  let!(:org)   { member.organization }
  let!(:ba)    { create :bank_account, organization: org }

  before do
    sign_in user
    visit root_path
  end

  subject { page }

  context 'accounts' do
    let!(:ba)    { create :bank_account, organization: org, balance: amount }

    it_behaves_like 'colorizable amount', 'table'
  end

  context 'total' do
    it 'display exhanged amount' do
      within '#total_balance' do
        expect(page).to have_content(
          money_with_symbol ba.balance.exchange_to(org.default_currency))
      end
    end

    it 'display exchange time' do
      within '#total_balance' do
        expect(page).to have_content("by Central Bank from #{I18n.l(Money.default_bank.rates_updated_at)}")
      end
    end

    it 'display exchange rate' do
      within '#total_balance' do
        expect(page).to have_xpath("//a[contains(concat(' ', @class, ' '), ' exchange-helper ') and contains(@title, '#{Money.default_bank.get_rate(ba.currency, org.default_currency).round(4)}')]")
      end
    end

    it 'display total balance in default currency' do
      within '#total_balance' do
        expect(page).to have_content("Total in #{org.default_currency}")
        expect(page).to have_content money_with_symbol (ba.balance.exchange_to(org.default_currency) + ba.balance.exchange_to(org.default_currency))
      end
    end

    context 'colorizable' do
      let!(:ba)     { create :bank_account, organization: org, balance: amount }

      it_behaves_like 'colorizable amount', '#total_balance'
    end
  end
end
