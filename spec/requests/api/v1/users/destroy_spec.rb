require 'rails_helper'

describe 'DELETE /api/users/#' do
  let(:path) { "/api/users/#{user.id}/" }

  let!(:user) { create :user }

  context 'unauthenticated' do
    it { delete(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as user' do
    before { delete path, headers: auth_header(user) }

    it 'delete transaction' do
      expect(response).to be_success
      expect(response.body).to be_empty

      expect(User.all).to eq []
    end
  end

  context 'authenticated as wrong user' do
    let!(:wrong_user) { create :user }

    before { delete path, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to be_forbidden
    end
  end
end
