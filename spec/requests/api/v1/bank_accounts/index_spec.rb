require 'rails_helper'

describe 'GET /api/organizations/#/bank_accounts' do
  let(:path) { "/api/organizations/#{organization.id}/bank_accounts" }

  let!(:user) { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:bank_account1) { create :bank_account, organization: organization }
  let!(:bank_account2) { create :bank_account, organization: organization }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as user' do
    before { get path, headers: auth_header(user) }

    it 'returns bank_accounts' do
      expect(response).to be_success

      expect(json[0]).to include(
        'id'       => bank_account2.id,
        'name'     => bank_account2.name,
        'currency' => bank_account2.currency,
        'balance'  => bank_account2.balance.as_json,
        'residue'  => bank_account2.residue.as_json,
      )
      expect(json[1]).to include(
        'id'       => bank_account1.id,
        'name'     => bank_account1.name,
        'currency' => bank_account1.currency,
        'balance'  => bank_account1.balance.as_json,
        'residue'  => bank_account1.residue.as_json,
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
