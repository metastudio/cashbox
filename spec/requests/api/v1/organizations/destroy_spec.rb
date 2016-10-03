require 'rails_helper'

describe 'DELETE /api/organizations/#' do
  let(:path) { "/api/organizations/#{organization.id}" }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, owner: owner, with_user: user }

  context 'unauthenticated' do
    it { delete(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as owner' do
    before { delete path, headers: auth_header(owner) }

    it 'delete organization' do
      expect(response).to be_success
      expect(response.body).to be_empty

      expect(Organization.all).to eq []
    end
  end

  context 'authenticated as user' do
    before { delete path, headers: auth_header(user) }

    it 'returns error' do
      expect(response).to be_forbidden
    end
  end
end
