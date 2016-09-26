require 'rails_helper'

describe 'GET /api/user_info' do
  let(:path) { "/api/user_info" }

  let!(:user) { create :user, password: 'password' }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated' do
    before { get path, headers: auth_header(user) }

    it 'returns current user information' do
      expect(response).to be_success

      expect(json['user']).to include(
        'id' => user.id,
        'email' => user.email,
        'full_name' => user.full_name
      )
    end
  end
end
