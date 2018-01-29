require 'rails_helper'

describe 'GET /api/organizations/#/total_balances' do
  let(:path) { "/api/organizations/#{organization.id}/total_balances" }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, owner: owner, with_user: user }
  let!(:usd_bank_account) { create :bank_account, organization: organization, currency: 'USD' }
  let!(:rub_bank_account) { create :bank_account, organization: organization, currency: 'RUB' }
  let!(:transaction1) { create :transaction, :income, :with_customer, bank_account: usd_bank_account, amount: 500 }
  let!(:transaction2) { create :transaction, :income, :with_customer, bank_account: rub_bank_account, amount: 500 }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as owner' do
    before { get path, headers: auth_header(owner) }

    it 'returns total_balances' do
      expect(response).to be_success

      expect(json).to include(
        'total_amount' => money_with_symbol(organization.total_balances.first[:total_amount]),
        'default_currency' => organization.default_currency,
      )
      expect(json['totals']).to include(
        'total' => money_with_symbol(organization.bank_accounts.total_balance('USD')),
        'currency' => 'USD',
        'ex_total' => nil,
        'rate' => nil,
        'updated_at' => nil
      )
      expect(json['totals']).to include(
        'total' => money_with_symbol(Money.new(50000, 'RUB')),
        'currency' => 'RUB',
        'ex_total' => money_with_symbol(organization.bank_accounts.total_balance('RUB').exchange_to('USD')),
        'rate' => Money.default_bank.get_rate('RUB', 'USD').round(4),
        'updated_at' => Money.default_bank.rates_updated_at.iso8601
      )
    end
  end

  context 'authenticated as user' do
    before { get path, headers: auth_header(owner) }

    it 'returns organization' do
      expect(response).to be_success

      expect(json).to include(
        'total_amount' => money_with_symbol(organization.total_balances.first[:total_amount]),
        'default_currency' => organization.default_currency,
      )
      expect(json['totals']).to include(
        'total' => money_with_symbol(organization.bank_accounts.total_balance('USD')),
        'currency' => 'USD',
        'ex_total' => nil,
        'rate' => nil,
        'updated_at' => nil
      )
      expect(json['totals']).to include(
        'total' => money_with_symbol(Money.new(50000, 'RUB')),
        'currency' => 'RUB',
        'ex_total' => money_with_symbol(organization.bank_accounts.total_balance('RUB').exchange_to('USD')),
        'rate' => Money.default_bank.get_rate('RUB', 'USD').round(4),
        'updated_at' => Money.default_bank.rates_updated_at.iso8601
      )
    end
  end
end
