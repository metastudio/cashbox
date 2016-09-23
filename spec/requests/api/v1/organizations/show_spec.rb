require 'rails_helper'

describe 'GET /api/organizations/#' do
  let(:path) { "/api/organizations/#{organization.id}" }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, owner: owner, with_user: user }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as owner' do
    before { get path, headers: auth_header(owner) }

    it 'returns organization' do
      expect(response).to be_success

      expect(json['organization']).to include(
        'id' => organization.id,
        'name' => organization.name,
        'default_currency' => organization.default_currency
      )
    end
  end

  context 'authenticated as user' do
    before { get path, headers: auth_header(owner) }

    it 'returns organization' do
      expect(response).to be_success

      expect(json['organization']).to include(
        'id' => organization.id,
        'name' => organization.name,
        'default_currency' => organization.default_currency
      )
    end
  end
end
