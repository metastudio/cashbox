require 'rails_helper'

describe 'DELETE /api/organizations/#/bank_accounts/#' do
  let(:path) { "/api/organizations/#{organization.id}/bank_accounts/#{bank_account.id}" }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, owner: owner, with_user: user }
  let!(:bank_account) { create :bank_account, organization: organization }

  context 'unauthenticated' do
    it { delete(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as owner' do
    before { delete path, headers: auth_header(owner) }

    it 'delete bank_account' do
      expect(response).to be_success
      expect(response.body).to be_empty

      bank_account.reload
      expect(bank_account.deleted_at).to_not eq nil
    end
  end

  context 'authenticated as user' do
    before { delete path, headers: auth_header(user) }

    it 'delete bank_account' do
      expect(response).to be_success
      expect(response.body).to be_empty

      bank_account.reload
      expect(bank_account.deleted_at).to_not eq nil
    end
  end

  context 'authenticated as wrong user' do
    let!(:wrong_user) { create :user }

    before { delete path, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to_not be_success
      expect(json).to be_empty

      bank_account.reload
      expect(bank_account.deleted_at).to eq nil
    end
  end
end
