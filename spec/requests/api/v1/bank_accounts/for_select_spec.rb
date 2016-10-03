require 'rails_helper'

describe 'GET /api/organizations/#/bank_accounts/for_select' do
  let(:path) { "/api/organizations/#{organization.id}/bank_accounts/for_select" }

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

    it 'returns bank_accounts for select' do
      expect(json[0]).to include(
        'value' => bank_account2.id,
        'label' => bank_account2.name,
      )
      expect(json[1]).to include(
        'value' => bank_account1.id,
        'label' => bank_account1.name,
      )
    end
  end

  context 'authenticated as user' do
    before { get path, headers: auth_header(user) }

    it 'returns bank_accounts for select' do
      expect(response).to be_success

      expect(json[0]).to include(
        'value' => bank_account2.id,
        'label' => bank_account2.name,
      )
      expect(json[1]).to include(
        'value' => bank_account1.id,
        'label' => bank_account1.name,
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
