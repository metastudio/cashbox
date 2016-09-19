require 'spec_helper'

describe 'GET /api/organizations' do
  let(:path) { "/api/organizations" }

  let!(:user) { create :user, :with_organizations }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as owner' do
    before { get path, headers: auth_header(user) }

    it 'returns organizations' do
      expect(response).to be_success

      expect(json['organizations']).to include(
        'id' => user.organizations.first.id,
        'name' => user.organizations.first.name,
        'default_currency' => user.organizations.first.default_currency
      )
      expect(json['organizations']).to include(
        'id' => user.organizations.last.id,
        'name' => user.organizations.last.name,
        'default_currency' => user.organizations.last.default_currency
      )
    end
  end
end
