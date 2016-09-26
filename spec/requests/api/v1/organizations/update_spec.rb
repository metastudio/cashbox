require 'rails_helper'

describe 'PUT /api/organizations/#' do
  let(:path) { "/api/organizations/#{organization.id}" }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, owner: owner, with_user: user }
  let(:params) {
      { organization: {
          name: 'Updated Organization Name',
          default_currency: 'RUB'
        }
      }
    }

  context 'unauthenticated' do
    it { put(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as owner' do
    before { put path, params: params, headers: auth_header(owner) }

    it 'returns updated organization' do
      expect(response).to be_success

      expect(json['organization']).to include(
        'id' => organization.id,
        'name' => 'Updated Organization Name',
        'default_currency' => 'RUB'
      )
    end

    context 'with wrong params' do
      let(:params) {
        { organization: {
            name: '',
            default_currency: 'RUB'
          }
        }
      }

      it 'returns error' do
        expect(response).to_not be_success

        expect(json['error']).to include "name" => ["can't be blank"]
      end
    end
  end

  context 'authenticated as user' do
    before { put path, params: params, headers: auth_header(user) }

    it 'returns error' do
      expect(response).to be_forbidden
    end
  end
end
