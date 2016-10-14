require 'rails_helper'

describe 'GET /api/organizations/#/bank_accounts' do
  let(:path) { "/api/organizations/#{organization.id}/bank_accounts" }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, owner: owner, with_user: user }
  let!(:bank_account1) { create :bank_account, organization: organization }
  let!(:bank_account2) { create :bank_account, organization: organization }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as owner' do
    before { get path, headers: auth_header(owner) }

    it 'returns bank_accounts' do
      expect(json[0]).to include(
        'id' => bank_account2.id,
        'name' => bank_account2.name,
        'currency' => bank_account2.currency,
        'balance' => money_with_symbol(bank_account2.balance),
        'residue' => money_with_symbol(bank_account2.residue)
      )
      expect(json[1]).to include(
        'id' => bank_account1.id,
        'name' => bank_account1.name,
        'currency' => bank_account1.currency,
        'balance' => money_with_symbol(bank_account1.balance),
        'residue' => money_with_symbol(bank_account1.residue)
      )
    end
  end

  context 'authenticated as user' do
    before { get path, headers: auth_header(user) }

    it 'returns bank_accounts' do
      expect(response).to be_success

      expect(json[0]).to include(
        'id' => bank_account2.id,
        'name' => bank_account2.name,
        'currency' => bank_account2.currency,
        'balance' => money_with_symbol(bank_account2.balance),
        'residue' => money_with_symbol(bank_account2.residue)
      )
      expect(json[1]).to include(
        'id' => bank_account1.id,
        'name' => bank_account1.name,
        'currency' => bank_account1.currency,
        'balance' => money_with_symbol(bank_account1.balance),
        'residue' => money_with_symbol(bank_account1.residue)
      )
    end
  end

  context 'authenticated as wrong user' do
    let!(:wrong_user) { create :user }

    before { get path, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to_not be_success
      expect(json).to be_empty
    end
  end
end
