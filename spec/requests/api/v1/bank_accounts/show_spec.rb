require 'rails_helper'

describe 'GET /api/organizations/#/bank_accounts/#' do
  let(:path) { "/api/organizations/#{organization.id}/bank_accounts/#{bank_account.id}" }

  let!(:user) { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:bank_account) { create :bank_account, organization: organization }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as user' do
    before { get path, headers: auth_header(user) }

    it 'returns bank_account' do
      expect(response).to be_success

      expect(json).to include(
        'id'          => bank_account.id,
        'name'        => bank_account.name,
        'description' => bank_account.description,
        'balance'     => bank_account.balance.as_json,
        'currency'    => bank_account.currency,
        'residue'     => bank_account.residue.as_json,
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
