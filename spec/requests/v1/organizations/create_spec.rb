require 'spec_helper'

describe 'POST /api/organizations' do
  let(:path) { "/api/organizations" }

  let!(:user) { create :user }

  context 'unauthenticated' do
    it { post(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated' do
    let(:params) {
        {
          organization: {
            name: 'Organization Name',
            default_currency: 'USD'
          }
        }
      }

    before { post path, params: params, headers: auth_header(user) }

    it 'returns created organization' do
      expect(response).to be_success

      expect(json['organization']).to include(
        'id' => Organization.last.id,
        'name' => 'Organization Name',
        'default_currency' => 'USD'
      )

      expect(Member.last.organization_id).to eq Organization.last.id
      expect(Member.last.user_id).to eq user.id
      expect(Member.last.role).to eq 'owner'
    end
  end
end
